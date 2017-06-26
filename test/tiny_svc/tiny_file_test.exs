defmodule TinySvc.TinyFileTest do
  use ExUnit.Case
  import Double
  alias TinySvc.TinyFile

  setup(context) do
    stub_contents = """
    HTTP GET /foo -> foo
    HTTP POST /bar -> bar
    http patch /boom -> boom
    """


    file_stub = File
    |> double
    |> allow(:read, fn("Tinyfile") -> {:ok, stub_contents} end)
    |> allow(:write!, fn(_filename, _contents) -> :ok end)

    Map.put(context, :deps, [file: file_stub])
  end

  describe "parse" do
    test "returns list of tuples", context do
      result = TinyFile.parse("Tinyfile", context.deps)
      assert result == [
        {"HTTP", ["GET", "/foo"], ["foo"]},
        {"HTTP", ["POST", "/bar"], ["bar"]},
        {"HTTP", ["patch", "/boom"], ["boom"]}
      ]
    end
  end

  describe "create" do
    test "creates a Tinyfile", context do
      service_name = "test-service"
      entries = [
        {"HTTP", ["GET", "/hello"], ["hello"]},
        {"HTTP", ["GET", "/foo"], ["foo", "bar"]}
      ]
      result = TinyFile.create(service_name, entries, context.deps)
      assert_receive {:write!, "services/test-service/Tinyfile", contents}
      assert contents |> String.contains?("HTTP GET /hello -> hello")
      assert contents |> String.contains?("HTTP GET /foo -> foo, bar")
    end
  end
end
