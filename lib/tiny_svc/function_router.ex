defmodule TinySvc.FunctionRouter do
  @moduledoc """
  Returns a list of functions responsible for handling a given service event.
  """

  alias TinySvc.Model.Model
  @deps [tiny_file: TinySvc.TinyFile]

  def route_http(service, %Model{} = model, deps \\ @deps) do
    service_dir = "services/#{service.name}"
    tiny_file_filename = "#{service_dir}/Tinyfile"
    tiny_file_spec = deps[:tiny_file].parse(tiny_file_filename)

    {model, funcs} = tiny_file_spec
    |> Enum.filter(fn({type, _, _}) ->
      type == "HTTP"
    end)
    |> Enum.reduce({model, []}, fn({_, [method, path], funcs}, {model, acc_funcs}) ->

      method_match = match_method?(method, model.req.method)
      path_match = path_match?(path, model.req.path_info)

      case {method_match, path_match} do
        {false, _} -> {model, acc_funcs}
        {true, {false, _}} -> {model, acc_funcs}
        {true, {true, path_params}} ->
          existing_params = model.req.path_params
          model = put_in(model.req.path_params, existing_params ++ path_params)
          {model, acc_funcs ++ funcs}
      end
    end)

    # put path params into params
    params = model.req.params
    model = put_in(model.req.params, params ++ model.req.path_params)

    {:ok, model, funcs}
  end

  defp match_method?(route_method, request_method) do
    String.upcase(route_method) == String.upcase(request_method)
  end

  defp path_match?(route_path, request_path_info) do
    route_path_info = Plug.Router.Utils.split(route_path)
    eq = route_path_info == request_path_info
    length_eq = Enum.count(route_path_info) == Enum.count(request_path_info)
    case {eq, length_eq} do
      {true, _} -> {true, []}
      {_, false} -> {false, []}
      {_, true} ->
        Enum.zip(route_path_info, request_path_info)
        |> Enum.reduce({true, []}, fn({route_part, request_part}, {match, path_params}) ->
          parts_match = request_part == route_part
          parameter_part = String.starts_with?(route_part, ":")
          case {match, parts_match, parameter_part} do
            {true, true, _} -> {true, path_params}
            {true, false, true} -> {true, path_params ++ [{String.trim(route_part, ":"), request_part}]}
            _ -> {false, []}
          end
        end)
    end
  end
end

