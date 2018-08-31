defmodule Ui.SwitchListener do
  require Logger
  alias Ui.Leds

  @push_button_1_pin Application.get_env(:ui, :button_1_pin, 26)

  defp gpio do
    if System.get_env("MIX_TARGET") != "host", do: ElixirALE.GPIO, else: NervesMocks.GPIO
  end

  # Return the listener pid for this supervised child
  # thus Supervisor.which_children returns that pid
  # and the `NervesMocks.GPIO` can find it to send
  # messages to the listener instead of this process.
  def start_link() do
    case gpio().start_link(@push_button_1_pin, :input) do
      {:ok, input_pid} -> 
        listener_pid = spawn(fn -> listen_forever(input_pid) end)
          {:ok, listener_pid}
      {:error, error} -> 
        Logger.error(inspect({:error_start_switch_listener, error}))
        {:error, error}
    end
  end

  defp listen_forever(input_pid) do
    gpio().set_int(input_pid, :both)
    listen_loop()
  end

  # Infinite loop receiving interrupts from gpio
  defp listen_loop() do
    receive do

      {:gpio_interrupt, p, :falling} ->
        UiWeb.Endpoint.broadcast("nerves:lobby", "button-pressed", %{ button: p })
        Leds.leds_off()

      {:gpio_interrupt, p, :rising} ->
        UiWeb.Endpoint.broadcast("nerves:lobby", "button-released", %{ button: p })
        Leds.random_leds()

    end

    listen_loop()
  end

end
