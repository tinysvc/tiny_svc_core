defmodule TinySvcLocal.FunctionHandler do
  @moduledoc """
  One worker per function. Manages the running OS process and invokes it via stdin/stdout
  """

  use GenServer
  @behaviour TinySvc.FunctionHandler

  alias Porcelain.Process, as: Proc
  alias TinySvc.Model.Model

  def init(state) do
    state = Keyword.put(state, :proc, spawn_function(state[:service], state[:function_name]))
    {:ok, state}
  end

  def start_link(service, function_name) do
    name = via_tuple(service, function_name)
    GenServer.start_link(__MODULE__, [service: service, function_name: function_name], name: name)
  end

  # Function Handler Callbacks

  def invoke(service, model, function_name) do
    start_link(service, function_name)
    name = via_tuple(service, function_name)
    GenServer.call(name, {:invoke, service, model, function_name})
  end

  # SERVER

  def handle_call({:invoke, service, model, function_name}, _from, state) do
    if Proc.alive?(state[:proc]) do
      proc_pid = state[:proc].pid

      data = Model.encode(model)
      |> Base.encode64

      Proc.send_input(state[:proc], data <> "\n")
      response = await_response(proc_pid, model.invocation_id)
      {:reply, {:ok, response}, state}
    else
      raise "Function process died for #{service.name}~#{function_name}"
    end
  end

  defp await_response(proc_pid, invocation_id) do
    prefix = invocation_id <> "~"
    receive do
      {^proc_pid, :data, :out, data} ->
        if String.starts_with?(data, prefix) do
          data = String.trim(data)
          |> String.split("~")
          |> List.last

          case data |> Base.decode64 do
            {:ok, bytes} -> Model.decode(bytes)
            _ -> false
          end
        end
    end || await_response(proc_pid, invocation_id)
  end

  defp spawn_function(service, function_name) do
    File.cd!("services/#{service.name}", fn ->
      Porcelain.spawn_shell("node harness.js #{function_name}", [in: :receive, out: {:send, self()}])
    end)
  end

  defp via_tuple(service, function_name) do
    identifier = "#{service.name}~#{function_name}"
    {:via, Registry, {:function_handler_registry, identifier}}
  end
end
