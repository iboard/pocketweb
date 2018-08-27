defmodule NervesMocks.GPIO do
  require Logger

  def start_link(pin, atom) do
    dictionary =
    case Agent.start_link( fn -> %{} end, name: __MODULE__) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end

    install_procs(pin, atom)

    {:ok, dictionary}
  end

  def set_int(_pid, _direction), do: nil
  def write(_pid, _value), do: nil

  defp install_procs(pin, :input) do
    spawn( fn -> initialize_button_loop(pin) end)
  end
  defp install_procs(pin, key), do: Logger.info(inspect { :i2c_mock, pin, key }) 

  # Depends on proper pid set at `Ui.SwitchListener.start_link/0`
  defp initialize_button_loop(pin) do
    {_,switch_listener,_,_} =
      Supervisor.which_children(Ui.Supervisor)
      |> Enum.find( fn({module,pid,_,_}) -> module == Ui.SwitchListener end)

    button_loop(switch_listener,pin)
  end

  defp button_loop(pid,pin) do
    :timer.sleep( Enum.random(1..20_000) )
    Logger.info( inspect {:random_button_press, pin } )
    send(pid, {:gpio_interrupt, pin, :falling})

    :timer.sleep( Enum.random(100..2000) )
    send(pid, {:gpio_interrupt, pin, :rising})

    button_loop(pid,pin)
  end
end
