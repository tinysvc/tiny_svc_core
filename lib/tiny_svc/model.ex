defmodule TinySvc.Model do
  @moduledoc """
  Common model used for messages sent to functions for processing.
  """
  use Protobuf, from: Path.join(:code.priv_dir(:tiny_svc_core), "model.proto")
end
