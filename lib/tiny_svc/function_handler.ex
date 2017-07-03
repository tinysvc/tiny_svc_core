defmodule TinySvc.FunctionHandler do
  @moduledoc """
  Behaviour for defining a FaaS compatible service.
  ex: Lambda or local function calls
  """

  @type function_name :: String.t
  @type service :: %TinySvc.Service{}
  @type model :: %TinySvc.Model.Model{}

  @callback invoke(service, model, function_name) :: {:ok, model} | {:error, any}
  @callback update(service, function_name) :: :ok | {:error, any}
end
