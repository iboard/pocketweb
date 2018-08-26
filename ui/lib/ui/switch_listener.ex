defmodule Ui.SwitchListener do
  require Logger

  alias Nerves.Leds
  alias ElixirALE.GPIO
  @input_pin 26

  def start_link() do
    if System.get_env("MIX_TARGET") != "host" do
      case GPIO.start_link(@input_pin, :input) do
        {:ok, input_pid} -> 
          spawn(fn -> listen_forever(input_pid) end)
        {:error, error} -> 
          Logger.error(inspect({:error_start_switch_listener, error}))
      end
    end
    {:ok, self()}
  end

  defp listen_forever(input_pid) do
    GPIO.set_int(input_pid, :both)
    listen_loop()
  end

  defp listen_loop() do
    # Infinite loop receiving interrupts from gpio
    receive do
      {:gpio_interrupt, p, :rising} ->
        Logger.debug("Received rising event on pin #{p}")
        UiWeb.Endpoint.broadcast("nerves:lobby", "button-released", %{ button: p })


      {:gpio_interrupt, p, :falling} ->
        Logger.debug("Received falling event on pin #{p}")
        UiWeb.Endpoint.broadcast("nerves:lobby", "button-pressed", %{ button: p })

    end

    listen_loop()
  end

end
