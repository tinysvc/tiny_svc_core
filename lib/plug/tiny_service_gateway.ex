defmodule Plug.TinyServiceGateway do
  import Plug.Conn
  alias TinySvc.Model.Model
  alias TinySvc.Model.Request
  alias TinySvc.Model.Cookie

  @deps [
    invoker: TinySvc.Invoker,
    router: TinySvc.FunctionRouter,
    service_manager: TinySvc.ServiceManager
  ]

  def init(_) do
    @deps
  end

  def call(conn, opts) do
    host      = conn.host
    root_host = Application.get_env(:tiny_svc_core, :root_host)
    if root_host == nil do
      raise "root_host is not configured for tiny_svc_core"
    end
    subdomain = String.replace(host, ~r/.?#{root_host}/, "")
    service   = opts[:service_manager].find(subdomain)

    conn = conn
    |> Plug.Conn.fetch_cookies
    |> Plug.Conn.fetch_query_params
    conn = Plug.Parsers.call(conn, [parsers: [Plug.Parsers.JSON, Plug.Parsers.URLENCODED], json_decoder: Poison])

    req = conn |> build_request_model

    {:ok, req, funcs} = opts[:router].route_http(service, req)
    req = update_path_params(req)
    function_name = funcs |> List.first # Assuming only one handler for http calls right now
    case function_name do
      nil -> not_found(conn)
      _ ->
        {:ok, res} = opts[:invoker].invoke(service, req, function_name)
        update_response_conn(res, conn)
    end
  end

  defp update_response_conn(response_model, conn) do
    if response_model.res do
      conn = response_model.res.headers
      |> Enum.reduce(conn, fn({k, v}, conn) ->
        put_resp_header(conn, k, v)
      end)
      |> resp(response_model.res.status, response_model.res.body)
      response_model.res.cookies
      |> Enum.reduce(conn, fn(cookie, conn) ->
        put_resp_cookie(conn, cookie.name, cookie.value)
      end)
    else
      conn
    end
  end

  defp build_request_model(conn) do
    req_cookies = conn.req_cookies
    |> Enum.map(fn({k, v}) ->
      Cookie.new(name: k, value: v)
    end)

    query_params = conn.query_params |> Map.to_list
    body_params = conn.body_params |> Map.to_list
    params = conn.params |> Map.to_list

    Model.new(
      req: Request.new(
        host: conn.host,
        method: conn.method,
        path: conn.request_path,
        query_string: conn.query_string,
        path_info: conn.path_info,
        query_params: query_params,
        body_params: body_params,
        params: params,
        cookies: req_cookies,
        headers: conn.req_headers
      )
    )
  end

  defp update_path_params(model) do
    params = model.req.params ++ model.req.path_params
    put_in(model.req.params, params)
  end

  defp not_found(conn) do
    send_resp(conn, 404, "not found")
  end
end
