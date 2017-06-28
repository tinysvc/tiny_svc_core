defmodule TinySvcLambda.FunctionHandler do
  @moduledoc """
  Super dumb aws function handler.  Just prototyping for now.
  """

  use GenServer
  @behaviour TinySvc.FunctionHandler

  alias Porcelain.Process, as: Proc
  alias TinySvc.Model.Model

  def invoke(service, model, function_name) do
    ensure_function_deployed(service, function_name)
    base64_message = model
    |> TinySvc.Model.Model.encode
    |> Base.encode64

    lambda_name = "#{service.name}-#{function_name}"

    {:ok, response} = lambda_name
    |> ExAws.Lambda.invoke(%{message: base64_message}, %{})
    |> ExAws.request

    case Map.get(response, "response_message") |> Base.decode64 do
      {:ok, bytes} -> {:ok, Model.decode(bytes)}
      _ -> {:error, "invalid response from aws lambda function"}
    end
  end

  defp ensure_function_deployed(service, function_name) do
    dir = "services/#{service.name}"
    harness_template = Path.join([:code.priv_dir(:tiny_svc_core), "templates", "aws_harness.js.eex"])
    harness_content = EEx.eval_file(harness_template, [function_name: function_name])
    harness_location = "#{dir}/aws_harness.js"
    File.write!(harness_location, harness_content)

    zipfilename = "#{service.name}.zip"
    {output, 0} = System.cmd("zip", ["-r", zipfilename, "."], cd: dir)

    push_to_lambda(service, function_name, zipfilename, dir)
    File.rm!("#{dir}/#{zipfilename}")
  end

  defp push_to_lambda(service, function_name, zipfilename, dir) do
    function_config = Application.get_env(:tiny_svc_core, :aws_function_config)
    lambda_name = "#{service.name}-#{function_name}"
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
end
