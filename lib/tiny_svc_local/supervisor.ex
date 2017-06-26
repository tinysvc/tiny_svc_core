defmodule TinySvcLocal.Supervisor do
  @moduledoc """
  Supervisor for the Local TinySVC strategy used for dev purposes
  """

  use Supervisor

  def start_link do
    Application.ensure_started(:porcelain)
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = []

    opts = [strategy: :one_for_one, name: TinySvcLocal.Supervisor]
    supervise(children, opts)
  end
end

