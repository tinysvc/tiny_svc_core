defmodule TinySvc.TinyFile do
  @moduledoc """
  Parses Tinyfiles for services
  """
  @deps [file: File]

  def create(service_name, tinyfile_entries, deps \\ @deps) do
    dir = "services/#{service_name}"
    tinyfile_entries = Enum.map(tinyfile_entries, fn({type, opts, funcs}) ->
      "#{type} #{Enum.join(opts, " ")} -> #{Enum.join(funcs, ", ")}"
    end)
    TinySvc.Utils.write_template(dir, "Tinyfile", [
      service_name: service_name,
      tinyfile_entries: tinyfile_entries
    ], deps)
  end

  def parse(filename, deps \\ @deps) do
    {:ok, contents} = deps[:file].read(filename)
    contents
    |> String.split("\n")
    |> Enum.filter(fn(line) ->
      String.length(line) > 0
    end)
    |> Enum.map(fn(line) ->
      type = line
      |> String.split(" ")
      |> List.first
      |> String.upcase

      opts = line
      |> String.split("->")
      |> List.first
      |> String.trim
      |> String.split(" ")
      |> Enum.drop(1)


      funcs = line
      |> String.split("->")
      |> List.last
      |> String.split(",")
      |> Enum.map(fn(func) -> String.trim(func) end)

      {type, opts, funcs}
    end)
  end
end
