defmodule TinySvc.FunctionHandler do
  @moduledoc """
  Behaviour for defining a FaaS compatible service.
  ex: Lambda or local function calls
  """

  @type function_name :: String.t
  @type service :: %TinySvc.Service{}
  @type model :: %TinySvc.Model.Model{}

  #@callback create_function(function_name, code_dir, filename, keyword) :: {:ok, any} | {:error, any}
  @callback invoke(service, model, function_name) :: {:ok, model} | {:error, any}
end
