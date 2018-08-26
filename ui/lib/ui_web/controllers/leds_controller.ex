defmodule UiWeb.LedsController do
  require Logger
  alias Nerves.Leds
  alias ElixirALE.GPIO
        
  @blue_led_pin 18
  @red_led_pin 24
  @green_led_pin 23

  use UiWeb, :controller

  def index(conn, params) do
    render(conn, "index.html")
  end

  def update(conn, params) do
    opts = %{ duration: duration, action: action, led_key: key } = cast(params)
    update_leds(opts)
    conn
    |> put_flash(:info, "LEDs UPDATE #{key}: #{inspect opts}")
    |> redirect(to: leds_path(conn, :index))
  end

  defp cast(params) do
    duration = param_to_int(params["duration"])
      
    %{ duration: duration,
      action: params["action"],
      led_key: params["led_key"]
    }
  end

  def update_leds( %{ duration: duration, led_key: key, action: action }) do
    IO.inspect({:update_leds, duration, action})
    Leds.set([
      { key, [ trigger: "timer", delay_off: duration, delay_on: duration ]}
    ])

    case action do
      "blue" -> switch_led_on(@blue_led_pin)
      "red" -> switch_led_on(@red_led_pin)
      "green" -> switch_led_on(@green_led_pin)

      "off" -> switch_leds_off
      _ -> Logger.warn("UNKNOWN ACTION RECEIVED #{action}")
    end
  end

  defp switch_led_on(pin) do
    case GPIO.start_link(pin, :output) do
      {:ok, output_pid} ->     GPIO.write(output_pid, 1)
      error -> IO.inspect({:ERROR_SWITCH_BLUE_LED, error})
    end
  end

  defp switch_leds_off do
    [@red_led_pin, @blue_led_pin, @green_led_pin]
    |> Enum.each( fn(pin) -> 
      case GPIO.start_link(pin, :output) do
        {:ok, output_pid} ->     GPIO.write(output_pid, 0)
        error -> IO.inspect({:ERROR_SWITCH_LED_OFF, pin, error})
      end
    end)
  end

  defp param_to_int(param) when param == "", do: 200
  defp param_to_int(param) when param == nil, do: 200
  defp param_to_int(param) when is_binary(param) do
    {v, _} = Integer.parse(param)
    v
  end
end
