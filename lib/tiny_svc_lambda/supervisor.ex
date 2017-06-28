defmodule TinySvcLambda.Supervisor do
  @moduledoc """
  Supervisor for the Lambda strategy
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = []

    opts = [strategy: :one_for_one, name: TinySvcLambda.Supervisor]
    supervise(children, opts)
  end
end

