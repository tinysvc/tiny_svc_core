defmodule TinySvc.InvokerTest do
  use ExUnit.Case
  import Double
  alias TinySvc.Invoker
  alias TinySvc.Service
  alias TinySvc.Model.Model

  describe "invoke" do
    setup(context) do
      function_handler_stub = TinySvcLocal.FunctionHandler
      |> double
      |> allow(:invoke, fn(_, model, _) -> {:ok, model} end)

      core_stub = TinySvcCore
      |> double
      |> allow(:strategy, fn(FunctionHandler) -> function_handler_stub end)

      deps = [core: core_stub]
      Map.put(context, :deps, deps)
    end

    test "invokes the configured function handler", %{deps: deps} do
      service = %Service{name: "foo"}
      model = Model.new()
      Invoker.invoke(service, model, "function_name", deps)
      assert_receive({:invoke, ^service, response_model, "function_name"})
      assert response_model.req == model.req
    end

    test "assigns an invocation id", %{deps: deps} do
      service = %Service{name: "foo"}
      model = Model.new()
      Invoker.invoke(service, model, "function_name", deps)
      assert_receive({:invoke, ^service, model, "function_name"})
      assert model.invocation_id
    end
  end
end

