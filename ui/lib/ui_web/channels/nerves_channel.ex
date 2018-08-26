defmodule UiWeb.NervesChannel do
  require Logger
  use UiWeb, :channel

  alias Nerves.Leds
  alias ElixirALE.GPIO

  @red_led_pin 24
  @blue_led_pin 18
  @green_led_pin 23

  def join("nerves:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("led-switched", payload, socket) do
    broadcast socket, "led-switched", payload
    case payload["led"] do
      "red" -> switch_led_on(@red_led_pin)
      "blue" -> switch_led_on(@blue_led_pin)
      "green" -> switch_led_on(@green_led_pin)
      "off" -> switch_leds_off()
    end
    {:reply, {:ok, payload}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
    
  defp switch_led_on(pin) do
    if System.get_env("MIX_TARGET") != "host" do
      case GPIO.start_link(pin, :output) do
        {:ok, output_pid} ->     GPIO.write(output_pid, 1)
        error -> IO.inspect({:ERROR_SWITCH_LED_ON, error})
      end
    end
    UiWeb.Endpoint.broadcast("nerves:lobby", "led-on", %{ led: pin })
  end

  defp switch_leds_off do
    if System.get_env("MIX_TARGET") != "host" do
      [@red_led_pin, @blue_led_pin, @green_led_pin]
      |> Enum.each( fn(pin) -> 
        case GPIO.start_link(pin, :output) do
          {:ok, output_pid} ->     GPIO.write(output_pid, 0)
          error -> IO.inspect({:ERROR_SWITCH_LED_OFF, pin, error})
        end
      end)
    end
    UiWeb.Endpoint.broadcast("nerves:lobby", "leds-off", %{})
  end


end
