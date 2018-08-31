defmodule Ui.Leds do
  use GenServer

  @red_led_pin Application.get_env(:ui, :red_led_pin, 24)
  @blue_led_pin Application.get_env(:ui, :blue_led_pin, 18)
  @green_led_pin Application.get_env(:ui, :green_led_pin, 23)

  defp gpio do
    if System.get_env("MIX_TARGET") != "host", do: ElixirALE.GPIO, else: NervesMocks.GPIO
  end

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    [{:red, red_pid, red_state}, {:blue, blue_pid, blue_state}, {:green, green_pid, green_state}] =
      initialize_leds()

    {:ok,
     %{red: {red_pid, red_state}, green: {green_pid, green_state}, blue: {blue_pid, blue_state}}}
  end

  def led_on(color) do
    GenServer.cast(__MODULE__, {:led_on, color})
  end

  def led_off(color) do
    GenServer.cast(__MODULE__, {:led_off, color})
  end

  def leds_off() do
    Enum.each([:red, :green, :blue], fn color -> led_off(color) end)
  end

  def random_leds() do
    red = Enum.random(0..1)
    green = Enum.random(0..1)
    blue = Enum.random(0..1)

    [{:red, red}, {:green, green}, {:blue, blue}]
    |> Enum.each(fn {color, is_on} -> if is_on == 1, do: led_on(color) end)
  end

  def handle_cast({:led_on, color}, state) do
    {output_pid, led} = state[color]

    unless led == :on do
      gpio().write(output_pid, 1)
      UiWeb.Endpoint.broadcast("nerves:lobby", "led-on", %{led: color})
    end

    {:noreply, state |> Map.merge(%{color => {output_pid, :on}})}
  end

  def handle_cast({:led_off, color}, state) do
    {output_pid, led} = state[color]

    unless led == :off do
      gpio().write(output_pid, 0)
      UiWeb.Endpoint.broadcast("nerves:lobby", "led-off", %{led: color})
    end

    {:noreply, state |> Map.merge(%{color => {output_pid, :off}})}
  end

  defp initialize_leds do
    [{:red, @red_led_pin}, {:blue, @blue_led_pin}, {:green, @green_led_pin}]
    |> Enum.map(fn {color, pin} ->
      case gpio().start_link(pin, :output) do
        {:ok, output_pid} ->
          gpio().write(output_pid, 1)
          {color, output_pid, :on}

        error ->
          IO.inspect({:ERROR_SWITCH_LED_ON, pin, error})
          {color, :error, :error}
      end
    end)
  end
end
