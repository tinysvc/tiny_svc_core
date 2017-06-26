defmodule Plug.TinyServiceGatewayTest do
  use ExUnit.Case
  use Plug.Test
  import Double
  alias Plug.TinyServiceGateway, as: GatewayPlug
  alias TinySvc.Model.Model, as: Model
  alias TinySvc.Model.Response
  alias TinySvc.Model.Cookie
  alias TinySvc.Service
  alias TinySvc.FunctionRouter

  setup(context) do
    service = %TinySvc.Service{name: "test-service"}
    context
    |> Map.put(:service, service)
  end

  describe "requests" do
    test "sends host", %{service: service} do
      conn = conn(:get, "/hello")
      |> assign(:service, service)
      %Plug.Conn{} = GatewayPlug.call(conn, stub_opts())
      assert_receive({:invoke, _service, model, "test_function"})
      assert model.req.host == "www.example.com"
    end

    test "sends method", %{service: service} do
      conn = conn(:get, "/hello")
      |> assign(:service, service)
      %Plug.Conn{} = GatewayPlug.call(conn, stub_opts())
      assert_receive({:invoke, _service, model, "test_function"})
      assert model.req.method == "GET"
    end

    test "sends path", %{service: service} do
      conn = conn(:get, "/hello")
      |> assign(:service, service)
      %Plug.Conn{} = GatewayPlug.call(conn, stub_opts())
      assert_receive({:invoke, _service, model, "test_function"})
      assert model.req.path == "/hello"
    end

    test "sends query string", %{service: service} do
      conn = conn(:get, "/hello?test=1&foo=bar")
      |> assign(:service, service)
      %Plug.Conn{} = GatewayPlug.call(conn, stub_opts())
      assert_receive({:invoke, _service, model, "test_function"})
      assert model.req.query_string == "test=1&foo=bar"
    end

    test "sends path info", %{service: service} do
      conn = conn(:get, "/hello/world")
      |> assign(:service, service)
      %Plug.Conn{} = GatewayPlug.call(conn, stub_opts())
      assert_receive({:invoke, _service, model, "test_function"})
      assert model.req.path_info == ["hello", "world"]
    end

    test "sends path params from function router" do
      function_router_stub = FunctionRouter
      |> double
      |> allow(:route_http, fn(_service, model) ->
        {
          :ok,
          put_in(model.req.path_params, [{"foo", "bar"}]),
          ["test_function"]
        }
      end)
      opts = stub_opts() |> Keyword.put(:router, function_router_stub)
      conn = conn(:get, "/hello")
      %Plug.Conn{} = GatewayPlug.call(conn, opts)
      assert_receive({:invoke, _service, model, "test_function"})
      assert model.req.path_params == [{"foo", "bar"}]
    end

    test "sends 404 when function router finds no matches" do
      function_router_stub = FunctionRouter
      |> double
      |> allow(:route_http, fn(_service, model) -> {:ok, model, []} end)
      opts = stub_opts() |> Keyword.put(:router, function_router_stub)
      conn = conn(:get, "/hello")
      conn = GatewayPlug.call(conn, opts)
      refute_receive({:invoke, _service, _, _})
      assert conn.status == 404
      assert conn.state == :sent
    end

    test "puts path_params into params" do
      function_router_stub = FunctionRouter
      |> double
      |> allow(:route_http, fn(_service, model) ->
        {
          :ok,
          put_in(model.req.path_params, [{"foo", "bar"}]),
          ["test_function"]
        }
      end)
      opts = stub_opts() |> Keyword.put(:router, function_router_stub)
      conn = conn(:get, "/hello")
      %Plug.Conn{} = GatewayPlug.call(conn, opts)
      assert_receive({:invoke, _service, model, "test_function"})
      assert model.req.params == [{"foo", "bar"}]
    end

    test "sends query params", %{service: service} do
      conn = conn(:get, "/hello?foo=bar")
      |> assign(:service, service)
      %Plug.Conn{} = GatewayPlug.call(conn, stub_opts())
      assert_receive({:invoke, _service, model, "test_function"})
      assert model.req.query_params == [{"foo", "bar"}]
    end

    test "sends body params", %{service: service} do
      conn = conn(:post, "/hello", "{\"foo\": \"bar\"}")
      |> assign(:service, service)
      |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = Plug.Parsers.call(conn, [parsers: [Plug.Parsers.JSON], json_decoder: Poison])
      %Plug.Conn{} = GatewayPlug.call(conn, stub_opts())
      assert_receive({:invoke, _service, model, "test_function"})
      assert model.req.body_params == [{"foo", "bar"}]
    end

    test "sends params", %{service: service} do
      conn = conn(:post, "/hello?test=1", "{\"foo\": \"bar\"}")
      |> assign(:service, service)
      |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = Plug.Parsers.call(conn, [parsers: [Plug.Parsers.JSON], json_decoder: Poison])
      %Plug.Conn{} = GatewayPlug.call(conn, stub_opts())
      assert_receive({:invoke, _service, model, "test_function"})
      assert model.req.params == [{"foo", "bar"}, {"test", "1"}]
    end

    test "sends cookies", %{service: service} do
      conn = conn(:get, "/hello")
      |> assign(:service, service)
      |> put_req_cookie("session", "random")
      %Plug.Conn{} = GatewayPlug.call(conn, stub_opts())
      assert_receive({:invoke, _service, model, "test_function"})
      assert model.req.cookies == [Cookie.new(name: "session", value: "random")]
    end

    test "sends headers", %{service: service} do
      conn = conn(:post, "/hello", "{\"foo\": \"bar\"}")
      |> assign(:service, service)
      |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = Plug.Parsers.call(conn, [parsers: [Plug.Parsers.JSON], json_decoder: Poison])
      %Plug.Conn{} = GatewayPlug.call(conn, stub_opts())
      assert_receive({:invoke, _service, model, "test_function"})
      assert model.req.headers == [{"content-type", "application/json"}]
    end

    test "sent message is serializable", %{service: service} do
      conn = conn(:post, "/hello")
      |> assign(:service, service)
      |> Plug.Parsers.call([parsers: [Plug.Parsers.JSON], json_decoder: Poison])
      %Plug.Conn{} = GatewayPlug.call(conn, stub_opts())
      assert_receive({:invoke, _service, model, "test_function"})
      bytes = Model.encode(model)
      decoded = Model.decode(bytes)
      assert decoded.req.path == "/hello"
    end
  end

  describe "responses" do
    test "sets response status according to returned model", %{service: service} do
      conn = conn(:get, "/hello")
      |> assign(:service, service)
      return_model = Model.new(res: Response.new(status: 404))
      result = GatewayPlug.call(conn, stub_opts(return_model))
      assert result.status == 404
    end

    test "sets body", %{service: service} do
      conn = conn(:get, "/hello")
      |> assign(:service, service)
      return_model = Model.new(res: Response.new(status: 404, body: "hello world"))
      result = GatewayPlug.call(conn, stub_opts(return_model))
      assert result.resp_body == "hello world"
    end

    test "sets response headers", %{service: service} do
      conn = conn(:get, "/hello")
      |> assign(:service, service)
      return_model = Model.new(res: Response.new(status: 404, headers: [{"foo", "bar"}]))
      result = GatewayPlug.call(conn, stub_opts(return_model))
      assert result.resp_headers |> Enum.member?({"foo", "bar"})
    end

    test "sets cookies", %{service: service} do
      conn = conn(:get, "/hello")
      |> assign(:service, service)
      return_model = Model.new(res: Response.new(status: 404, cookies: [
        Cookie.new(name: "foo", value: "bar")
      ]))
      result = GatewayPlug.call(conn, stub_opts(return_model))
      assert result.resp_cookies == %{"foo" => %{value: "bar"}}
    end
  end

  defp stub_opts(return_model \\ Model.new()) do
    invoker_stub = TinySvc.Invoker
    |> double
    |> allow(:invoke, fn(_service, _model, _function_name) -> {:ok, return_model} end)

    router_stub = FunctionRouter
    |> double
    |> allow(:route_http, fn(_service, model) -> {:ok, model, ["test_function"]} end)

    service_manager_stub = TinySvc.ServiceManager
    |> double
    |> allow(:find, fn(name) -> %Service{name: name} end)

    [invoker: invoker_stub, router: router_stub, service_manager: service_manager_stub]
  end

  def stub_model do
    Model.new(res: Response.new(status: 200))
  end
end

