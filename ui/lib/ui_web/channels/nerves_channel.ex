defmodule UiWeb.NervesChannel do
  require Logger
  use UiWeb, :channel

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
      "red" -> Ui.SwitchListener.led_on(:red)
      "blue" -> Ui.SwitchListener.led_on(:blue)
      "green" -> Ui.SwitchListener.led_on(:green)
      "off" -> Ui.SwitchListener.leds_off()
    end
    {:reply, {:ok, payload}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
    

end
