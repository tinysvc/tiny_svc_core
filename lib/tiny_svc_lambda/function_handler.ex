defmodule TinySvcLambda.FunctionHandler do
  use GenServer
  @behaviour TinySvc.FunctionHandler

  alias TinySvc.Model.Model

  def init(state) do
    {:ok, state}
  end

  def start_link(service, function_name) do
    {_name, result} = ensure_started(service, function_name)
    result
  end

  def invoke(service, model, function_name) do
    base64_message = model
    |> TinySvc.Model.Model.encode
    |> Base.encode64

    lambda_name = lambda_name(service, function_name)

    {:ok, response} = lambda_name
    |> ExAws.Lambda.invoke(%{message: base64_message}, %{})
    |> ExAws.request

    case Map.get(response, "response_message") |> Base.decode64 do
      {:ok, bytes} -> {:ok, Model.decode(bytes)}
      _ -> {:error, "invalid response from aws lambda function"}
    end
  end

  def update(service, function_name) do
    {name, _} = ensure_started(service, function_name)
    GenServer.cast(name, {:update, service, function_name})
  end

  def handle_cast({:update, service, function_name}, state) do
    dir = "services/#{service.name}"
    zipfilename = "#{service.name}.zip"
    harness_template = Path.join([:code.priv_dir(:tiny_svc_core), "templates", "aws_harness.js.eex"])
    harness_content = EEx.eval_file(harness_template, [function_name: function_name])
    harness_location = "#{dir}/aws_harness.js"
    File.write!(harness_location, harness_content)

    {output, 0} = System.cmd("zip", ["-r", zipfilename, ".", "-x", "*.zip"], cd: dir)

    push_to_lambda(service, function_name, zipfilename, dir)
    {:noreply, state}
  end

  defp via_tuple(service, function_name) do
    identifier = "#{service.name}~#{function_name}"
    {:via, Registry, {:function_handler_registry, identifier}}
  end

  defp ensure_started(service, function_name) do
    name = via_tuple(service, function_name)
    {name, GenServer.start_link(__MODULE__, [service: service, function_name: function_name], name: name)}
  end

  defp push_to_lambda(service, function_name, zipfilename, dir) do
    function_config = Application.get_env(:tiny_svc_core, :aws) |> Map.get(:function_config)
    lambda_name = lambda_name(service, function_name)
    {:ok, bytes} = File.read("#{dir}/#{zipfilename}")
    data = Base.encode64(bytes)
    request = ExAws.Lambda.create_function(lambda_name, "aws_harness.handler", data, function_config)
    case ExAws.request(request) do
      {:ok, _} -> nil
      {:error, {:http_error, 409, _}} ->
        # try updating the function code when it already exists
        {:ok, _} = ExAws.Lambda.update_function_code(lambda_name, data) |> ExAws.request
    end
  end

  defp lambda_name(service, function_name) do
    env = Application.get_env(:tiny_svc_core, :aws) |> Map.get(:function_env)
    "#{env}_#{service.name}_#{function_name}"
  end
end
