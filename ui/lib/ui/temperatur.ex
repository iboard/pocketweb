defmodule Ui.Temperature do

  @measure_interval Application.get_env(:ui, :measure_interval, 5_000)

  defp i2c do
    if System.get_env("MIX_TARGET") != "host", do: ElixirALE.I2C, else: NervesMocks.I2C
  end

  def start_link() do
    {:ok, sensors} = i2c().start_link("i2c-1", 0x48)
    spawn(fn -> loop(%{sensors: sensors}) end)
    {:ok, self()}
  end

  def loop(%{sensors: sensors} = state) do
    celsius = read_celsius(sensors, 0)
    farenheit = celcius_to_farenheit(celsius)
    set_leds(celsius)
    broadcast({celsius, farenheit})
    :timer.sleep(@measure_interval)
    loop(state)
  end

  defp set_leds(celsius) when celsius < 17 do
    Ui.Leds.led_on(:blue)
    Ui.Leds.led_off(:green)
    Ui.Leds.led_off(:red)
  end
  defp set_leds(celsius) when celsius < 20 do
    Ui.Leds.led_on(:blue)
    Ui.Leds.led_on(:green)
    Ui.Leds.led_off(:red)
  end
  defp set_leds(celsius) when celsius < 22 do
    Ui.Leds.led_off(:blue)
    Ui.Leds.led_on(:green)
    Ui.Leds.led_off(:red)
  end
  defp set_leds(celsius) when celsius < 25 do
    Ui.Leds.led_off(:blue)
    Ui.Leds.led_on(:green)
    Ui.Leds.led_on(:red)
  end
  defp set_leds(_) do
    Ui.Leds.led_off(:blue)
    Ui.Leds.led_off(:green)
    Ui.Leds.led_on(:red)
  end

  defp broadcast({celsius, farenheit}) do
    str_c = to_string(:io_lib.format("~6.2f", [celsius]))
    str_f = to_string(:io_lib.format("~6.2f", [farenheit]))
    UiWeb.Endpoint.broadcast("nerves:lobby", "temperature", %{celsius: str_c, farenheit: str_f})
  end

  defp celcius_to_farenheit(celsius) do
    celsius * (9 / 5) + 32.0
  end

  defp read_celsius(sensors, register) do
    advalue = read_sensor(sensors, register)
    volt = advalue * 3.3 / 255.0

    rt = 10 * volt / (3.3 - volt)
    temp_k = 1 / (1 / (273.15 + 25) + :math.log(rt / 10) / 3950)
    temp_k - 273.15
  end

  defp read_sensor(pid, channel) do
    {channel_value, _} = Integer.parse("#{channel + 40}", 16)
    i2c().write(pid, <<channel_value>>)
    i2c().read(pid, 1)
    <<value>> = i2c().read(pid, 1)
    value
  end
end
