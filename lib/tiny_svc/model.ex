defmodule TinySvc.Model do
  @moduledoc """
  Common model used for messages sent to functions for processing.
  """
  use Protobuf, from: Path.expand("../../model.proto", __DIR__)
end
