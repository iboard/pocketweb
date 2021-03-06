# Pocket Web Firmware

**For Raspberry Pi 3**

### BREADBOARD CIRCUIT

      LEDS:
      
      <PIN 18>-----<BLUE  LED>----<220Ohm>----<GRD>
      <PIN 23>-----<GREEN LED>----<220Ohm>----<GRD>
      <PIN 24>-----<RED   LED>----<220Ohm>----<GRD>

      PUSH-BUTTON:

      <PIN 26>-----<10kOhm>---+---<10kOhm>----<+3V>
                              |
                              ----<BUTTON>----<GRD>

## Targets

Nerves applications produce images for hardware targets based on the
`MIX_TARGET` environment variable. If `MIX_TARGET` is unset, `mix` builds an
image that runs on the host (e.g., your laptop). This is useful for executing
logic tests, running utilities, and debugging. Other targets are represented by
a short name like `rpi3` that maps to a Nerves system image for that platform.
All of this logic is in the generated `mix.exs` and may be customized. For more
information about targets see:

https://hexdocs.pm/nerves/targets.html#content

## Getting Started

To start your Nerves app:
  * `export MIX_TARGET=my_target` or prefix every command with
    `MIX_TARGET=my_target`. For example, `MIX_TARGET=rpi3`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix firmware.burn`

## Learn more

  * Official docs: https://hexdocs.pm/nerves/getting-started.html
  * Official website: http://www.nerves-project.org/
  * Discussion Slack elixir-lang #nerves ([Invite](https://elixir-slackin.herokuapp.com/))
  * Source: https://github.com/nerves-project/nerves
