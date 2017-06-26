defmodule TinySvcLocal.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start do
    start(nil, nil)
  end
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    tiny_svc_port = Application.get_env(:tiny_svc_core, :port)
    if tiny_svc_port == nil do
      raise "port is not configured for tiny_svc_core"
    end

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: TinySvcLocal.Worker.start_link(arg1, arg2, arg3)
      # worker(TinySvcLocal.Worker, [arg1, arg2, arg3]),
      Plug.Adapters.Cowboy.child_spec(:http, Plug.TinyServiceGateway, [], [port: tiny_svc_port]),
      supervisor(Registry, [:unique, :local_function_handler_registry])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TinySvcLocal.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
