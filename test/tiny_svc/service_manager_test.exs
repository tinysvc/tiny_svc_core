defmodule TinySvc.ServiceManagerTest do
  use ExUnit.Case
  import Double
  alias TinySvc.Service
  alias TinySvc.ServiceManager

  test "returns a service struct" do
    result = ServiceManager.find("test-service", [file: file_stub(true)])
    assert result == %Service{name: "test-service"}
  end

  test "when missing, returns nil" do
    result = ServiceManager.find("test-service", [file: file_stub(false)])
    assert result == nil
  end

  defp file_stub(result) do
    File
    |> double
    |> allow(:exists?, fn("services/test-service") -> result end)
  end
end
