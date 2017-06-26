defmodule TinySvc.InvokerTest do
  use ExUnit.Case
  import Double
  alias TinySvc.Invoker
  alias TinySvc.Service
  alias TinySvc.Model.Model

  describe "invoke" do
    test "invokes the configured function handler" do
      function_handler_stub = TinySvc.FunctionHandler
      |> double
      |> allow(:invoke, fn(_, model, _) -> {:ok, model} end)

      application_stub = Application
      |> double
      |> allow(:get_env, fn(:tiny_svc_core, :function_handler) -> function_handler_stub end)

      service = %Service{name: "foo"}
      model = Model.new()
      deps = [application: application_stub]
      Invoker.invoke(service, model, "function_name", deps)
      assert_receive({:invoke, ^service, response_model, "function_name"})
      assert response_model.req == model.req
    end

    test "assigns an invocation id" do
      function_handler_stub = TinySvc.FunctionHandler
      |> double
      |> allow(:invoke, fn(_, model, _) -> {:ok, model} end)

      application_stub = Application
      |> double
      |> allow(:get_env, fn(:tiny_svc_core, :function_handler) -> function_handler_stub end)

      service = %Service{name: "foo"}
      model = Model.new()
      deps = [application: application_stub]
      Invoker.invoke(service, model, "function_name", deps)
      assert_receive({:invoke, ^service, model, "function_name"})
      assert model.invocation_id
    end
  end
end

