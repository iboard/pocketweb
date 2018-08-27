defmodule Ui.Leds do

  @red_led_pin 24
  @blue_led_pin 18
  @green_led_pin 23

  def gpio do
    if System.get_env("MIX_TARGET") != "host", do: ElixirALE.GPIO, else: NervesMocks.GPIO
  end

  def leds_off() do
    [@red_led_pin, @blue_led_pin, @green_led_pin]
    |> Enum.each( fn(pin) -> 
      case gpio().start_link(pin, :output) do
        {:ok, output_pid} ->     gpio().write(output_pid, 0)
        error -> IO.inspect({:ERROR_SWITCH_LED_OFF, pin, error})
      end
    end)
    UiWeb.Endpoint.broadcast("nerves:lobby", "led-switched", %{led: :off})
  end

  def led_on(color) do
    pin =
      case color do
        :green -> @green_led_pin
        :blue -> @blue_led_pin
        :red -> @red_led_pin
      end

    case gpio().start_link(pin, :output) do
      {:ok, output_pid} ->     gpio().write(output_pid, 1)
      error -> IO.inspect({:ERROR_SWITCH_LED_ON, error})
    end
    UiWeb.Endpoint.broadcast("nerves:lobby", "led-switched", %{led: color})
  end

  def random_leds() do
    red = Enum.random(0..1)
    green = Enum.random(0..1)
    blue = Enum.random(0..1)
    [{:red,red},{:green, green},{:blue, blue}]
    |> Enum.each( fn({color, is_on}) ->
      if is_on == 1, do: led_on(color)
    end)
  end

end
