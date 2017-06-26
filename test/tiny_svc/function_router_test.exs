defmodule TinySvc.FunctionRouterTest do
  use ExUnit.Case
  import Double

  alias TinySvc.Service
  alias TinySvc.TinyFile
  alias TinySvc.Model.Model
  alias TinySvc.Model.Request
  alias TinySvc.FunctionRouter

  describe "http requests" do
    setup(context) do
      tiny_file_data = [
        {"HTTP", ["GET", "/bar"], ["bar"]},
        {"HTTP", ["GET", "/foo"], ["foo"]},
        {"HTTP", ["GET", "/pets/:id"], ["show_pet"]}
      ]

      tiny_file_stub = TinyFile
      |> double
      |> allow(:parse, fn("services/foo/Tinyfile") -> tiny_file_data end)

      service = %Service{name: "foo"}

      model = Model.new(
        req: Request.new(
          host: "foo.tinysvc.dev",
          method: "GET",
          path: "/pets",
          path_info: ["pets"],
        )
      )

      Map.merge(context, %{
        model: model,
        service: service,
        deps: [tiny_file: tiny_file_stub]
      })
    end

    test "returns exact match funcs", context do
      context = put_in(context.model.req.path, "/foo")
      context = put_in(context.model.req.path_info, ["foo"])
      context = put_in(context.model.req.method, "GET")

      {:ok, _model, funcs} = FunctionRouter.route_http(context.service, context.model, context.deps)
      assert funcs == ["foo"]
    end

    test "returns url parameterized funcs", context do
      context = put_in(context.model.req.path, "/pets/1")
      context = put_in(context.model.req.path_info, ["pets", "1"])
      context = put_in(context.model.req.method, "GET")

      {:ok, _model, funcs} = FunctionRouter.route_http(context.service, context.model, context.deps)
      assert funcs == ["show_pet"]
    end

    test "populates path_params and params from parameterized routes", context do
      context = put_in(context.model.req.path, "/pets/1")
      context = put_in(context.model.req.path_info, ["pets", "1"])
      context = put_in(context.model.req.method, "GET")

      {:ok, model, _funcs} = FunctionRouter.route_http(context.service, context.model, context.deps)
      assert model.req.path_params == [{"id", "1"}]
      assert model.req.params |> Enum.member?({"id", "1"})
    end
  end
end
