defmodule Ui.Temperature do

  alias ElixirALE.I2C

  def i2c do
    if System.get_env("MIX_TARGET") != "host", do: ElixirALE.I2C, else: NervesMocks.I2C
  end


  def start_link() do
    if System.get_env("MIX_TARGET") != "host" do
      {:ok, sensors} = i2c().start_link("i2c-1", 0x48)
      spawn(fn -> loop(%{sensors: sensors}) end)
    else
      spawn(fn -> loop(%{sensors: -1}) end)
    end
    {:ok, self()}
  end

  def loop(%{sensors: sensors} = state) do
    celsius = read_celsius(sensors,0)
    farenheit = celcius_to_farenheit(celsius)
    str_c = to_string(:io_lib.format("~6.2f", [celsius]))
    str_f = to_string(:io_lib.format("~6.2f", [farenheit]))
    UiWeb.Endpoint.broadcast("nerves:lobby", "temperature", %{ celsius: str_c, farenheit: str_f })
    :timer.sleep(1000)
    loop(state)
  end

  defp celcius_to_farenheit(celsius) do
    celsius * (9/5) + 32.0
  end

  defp read_celsius(sensors,register) do
    advalue = read_sensor(sensors,register)
    volt = advalue*3.3/255.0;

    rt = 10*volt / (3.3-volt)
    temp_k = 1/(1/(273.15+25) + :math.log(rt/10)/3950)
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
