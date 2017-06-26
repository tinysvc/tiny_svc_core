defmodule TinySvc.Invoker do
  @moduledoc """
  Invokes functions on configured function handler
  """

  @deps [application: Application]

  def invoke(service, model, function_name, deps \\ @deps) do
    model = put_in(model.invocation_id, UUID.uuid4())
    function_handler = deps[:application].get_env(:tiny_svc_core, :function_handler)
    if function_handler == nil do
      raise "function_handler is not configured for tiny_svc"
    end

    function_handler.invoke(service, model, function_name)
  end
end
