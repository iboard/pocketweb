defmodule UiWeb.LedsController do
  require Logger
  alias Nerves.Leds

  @blue_led_pin 18
  @red_led_pin 24
  @green_led_pin 23

  use UiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def update(conn, params) do
    with opts = %{duration: _duration, action: _action, led_key: key} = cast(params),
         update_leds(opts) do
      conn
      |> put_flash(:info, "LEDs UPDATE #{key}: #{inspect(opts)}")
      |> redirect(to: leds_path(conn, :index))
    end
  end

  defp cast(params) do
    duration = param_to_int(params["duration"])

    %{duration: duration, action: params["action"], led_key: params["led_key"]}
  end

  def update_leds(%{duration: duration, led_key: key, action: action}) do
    case action do
      "blue" -> Ui.Leds.led_on(@blue_led_pin)
      "red" -> Ui.Leds.led_on(@red_led_pin)
      "green" -> Ui.Leds.led_on(@green_led_pin)
      "set" -> set_leds(key, duration)
      "off" -> Ui.Leds.leds_off()
      _ -> Logger.warn("UNKNOWN ACTION RECEIVED #{action}")
    end
  end

  defp set_leds(key, duration) do
    if System.get_env("MIX_TARGET") != "host" do
      Leds.set([
        {key, [trigger: "timer", delay_off: duration, delay_on: duration]}
      ])
    end
  end

  defp param_to_int(param) when param == "", do: 200
  defp param_to_int(param) when param == nil, do: 200

  defp param_to_int(param) when is_binary(param) do
    {v, _} = Integer.parse(param)
    v
  end
end
