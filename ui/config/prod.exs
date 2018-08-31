use Mix.Config

config :ui, UiWeb.Endpoint,
  load_from_system_env: true,
  url: [host: System.get_env("MIX_HOST"), port: System.get_env("MIX_PORT")],
  port: System.get_env("MIX_PORT"),
  cache_static_manifest: "priv/static/cache_manifest.json",
  debug_errors: false,
  check_origin: false,
  measure_interval: 5_000,
  red_led_pin: 24,
  blue_led_pin: 18,
  green_led_pin: 23,
  button_1_pin: 26

config :logger, level: :info

import_config "prod.secret.exs"
