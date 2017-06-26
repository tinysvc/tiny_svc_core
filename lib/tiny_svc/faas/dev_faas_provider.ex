defmodule TinySvc.Faas.DevProvider do
  @moduledoc """
  FaaS provider meant for local development.
  """

  @behaviour TinyFaas.FaasProvider

  def create_function(function_name, code, keyword, opts) do
    {:error, "not implemented"}
  end

  def invoke(function_name, function_args) do
    {:error, "not implemented"}
  end
end
