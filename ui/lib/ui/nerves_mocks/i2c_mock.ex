defmodule NervesMocks.I2C do
  require Logger

  def start_link(device_name, address) do
    dictionary =
    case Agent.start_link( fn -> %{} end, name: __MODULE__) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
    Logger.info( inspect({:i2c_start_link, device_name, address}) )
    {:ok, dictionary}
  end

  def write(_pid, _channel), do: nil
  def read(_pid, _channel) do
    r = Enum.random((1..254))
    <<r>>
  end
end

