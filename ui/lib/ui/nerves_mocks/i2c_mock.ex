defmodule NervesMocks.I2C do

  def start_link(device_name, address) do
    Agent.start_link( fn -> {device_name, address} end)
  end

  def write(_pid, _channel), do: nil
  def read(_pid, _channel) do
    r = Enum.random((1..255))
    <<r>>
  end
end

