defmodule TinySvc.Invoker do
  @moduledoc """
  Invokes functions on configured function handler
  """

  @deps [core: TinySvcCore]

  def invoke(service, model, function_name, deps \\ @deps) do
    model = put_in(model.invocation_id, UUID.uuid4())
    deps[:core].strategy(FunctionHandler).invoke(service, model, function_name)
  end
end
