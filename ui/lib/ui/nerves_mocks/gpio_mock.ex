defmodule NervesMocks.GPIO do

  def start_link(pin, atom) do
    Agent.start_link( fn -> {pin, atom} end)
  end

  def set_int(_pid, _direction), do: nil
  def write(_pid, _value), do: nil
end
