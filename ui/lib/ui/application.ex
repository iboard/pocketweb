defmodule Ui.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(UiWeb.Endpoint, []),
      worker(Ui.Leds, [], restart: :permanent),
      worker(Ui.SwitchListener, [], restart: :permanent),
      worker(Ui.Temperature, [], restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: Ui.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    UiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
