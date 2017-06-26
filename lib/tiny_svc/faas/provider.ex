defmodule TinySvc.Faas.Provider do
  @moduledoc """
  Behaviour for defining a FaaS compatible service.
  ex: Lambda or local function calls
  """

  @type function_name :: String.t
  @type function_args :: any
  @type code_dir :: String.t
  @type filename :: String.t

  @doc """
  - function_name - A unique id for the function
  - code_dir - location of the code files to be packaged
  - filename - name of file to be used as the function handler
  - options - additional options specific to provider
  """
  @callback create_function(function_name, code_dir, filename, keyword) :: {:ok, any} | {:error, any}
  @callback invoke(function_name, function_args) :: {:ok, any} | {:error, any}
end
