defmodule Ui.Temperature do

  alias ElixirALE.I2C

  def start_link() do
    if System.get_env("MIX_TARGET") != "host" do
      {:ok, sensors} = I2C.start_link("i2c-1", 0x48)
      spawn(fn -> loop(%{sensors: sensors}) end)
    else
      spawn(fn -> loop(%{sensors: -1}) end)
    end
    {:ok, self()}
  end

  def loop(%{sensors: sensors} = state) do
    celcius = read_celcius(sensors,0)
    UiWeb.Endpoint.broadcast("nerves:lobby", "temperature", %{ celcius: celcius })
    :timer.sleep(1000)
    loop(state)
  end

  defp read_celcius(sensors,register) do
    advalue = read_sensor(sensors,register)
    volt = advalue*3.3/255.0;

    rt = 10*volt / (3.3-volt)
    temp_k = 1/(1/(273.15+25) + :math.log(rt/10)/3950)
    temp_c = temp_k - 273.15
    to_string(:io_lib.format("~6.2f~n", [temp_c]))
  end

   defp read_sensor(pid, channel) when pid == -1 do
     channel_value = Enum.random((0..255))
   end
   defp read_sensor(pid, channel) do
    {channel_value, _} = Integer.parse("#{channel + 40}", 16)
    I2C.write(pid, <<channel_value>>)
    I2C.read(pid, 1)
    <<value>> = I2C.read(pid, 1)
    value
  end


end
