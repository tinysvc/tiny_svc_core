defmodule TinySvcCore do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    port = Application.get_env(:tiny_svc_core, :port)
    if port == nil do
      raise "port is not configured for tiny_svc_core"
    end

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Plug.TinyServiceGateway, [], [port: port])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TinySvcWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TinySvcWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
