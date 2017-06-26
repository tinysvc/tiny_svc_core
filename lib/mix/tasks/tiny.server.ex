defmodule Mix.Tasks.Tiny.Server do
  use Mix.Task

  @shortdoc "Runs the TinySVC dev server"
  def run(args) do
    Application.ensure_all_started(:tiny_svc_core)
    TinySvcLocal.Application.start
    Mix.Tasks.Run.run run_args() ++ args
  end

  defp run_args do
    if iex_running?(), do: [], else: ["--no-halt"]
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) and IEx.started?
  end
end
