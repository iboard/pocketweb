defmodule Ui.SwitchListener do
  require Logger

  alias ElixirALE.GPIO

  @red_led_pin 24
  @blue_led_pin 18
  @green_led_pin 23
  @push_button_1_pin 26


  def start_link() do
    if System.get_env("MIX_TARGET") != "host" do
      case GPIO.start_link(@push_button_1_pin, :input) do
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
        random_leds()


      {:gpio_interrupt, p, :falling} ->
        Logger.debug("Received falling event on pin #{p}")
        UiWeb.Endpoint.broadcast("nerves:lobby", "button-pressed", %{ button: p })
        leds_off()

    end

    listen_loop()
  end

  def leds_off() do
    if System.get_env("MIX_TARGET") != "host" do
      [@red_led_pin, @blue_led_pin, @green_led_pin]
      |> Enum.each( fn(pin) -> 
        case GPIO.start_link(pin, :output) do
          {:ok, output_pid} ->     GPIO.write(output_pid, 0)
          error -> IO.inspect({:ERROR_SWITCH_LED_OFF, pin, error})
        end
      end)
    end
    UiWeb.Endpoint.broadcast("nerves:lobby", "led-switched", %{led: :off})
  end

  def led_on(color) do
    pin =
      case color do
        :green -> @green_led_pin
        :blue -> @blue_led_pin
        :red -> @red_led_pin
      end

    if System.get_env("MIX_TARGET") != "host" do
      case GPIO.start_link(pin, :output) do
        {:ok, output_pid} ->     GPIO.write(output_pid, 1)
        error -> IO.inspect({:ERROR_SWITCH_LED_ON, error})
      end
    end
    UiWeb.Endpoint.broadcast("nerves:lobby", "led-switched", %{led: color})
  end

  defp random_leds() do
    red = Enum.random(0..1)
    green = Enum.random(0..1)
    blue = Enum.random(0..1)
    [{:red,red},{:green, green},{:blue, blue}]
    |> Enum.each( fn({color, is_on}) ->
      if is_on == 1, do: led_on(color)
    end)
  end

end
