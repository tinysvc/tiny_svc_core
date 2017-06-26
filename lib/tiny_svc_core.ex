defmodule TinySvcCore do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    port = Application.get_env(:tiny_svc_core, :port)
    if port == nil do
      raise "port is not configured for tiny_svc_core"
    end

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Plug.TinyServiceGateway, [], [port: port]),
      supervisor(Registry, [:unique, :function_handler_registry]),
      supervisor(strategy(Supervisor), [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TinySvcWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def strategy(mod \\ nil) do
    case {Application.get_env(:tiny_svc_core, :strategy), mod} do
      {nil, _} -> raise "strategy not configured for tiny_svc_core!"
      {strategy, nil} -> strategy
      {strategy, mod} -> Module.concat(strategy, mod)
    end
  end
end
