defmodule TinySvc.Service do
  defstruct name: nil

  @deps [file: File, tinyfile: TinySvc.TinyFile, system: System]

  def init_folder(%TinySvc.Service{name: name}, tinyfile_entries, extra_files, deps \\ @deps) do
    dir = "services/#{name}"
    File.mkdir_p!(dir)
    deps[:tinyfile].create(name, tinyfile_entries)
    TinySvc.Utils.write_template(dir, {:tiny_svc_core, "harness.js"}, [], deps)
    TinySvc.Utils.write_template(dir, {:tiny_svc_core, "package.json"}, [service_name: name], deps)
    extra_files
    |> Enum.each(fn({name, content}) ->
      deps[:file].write!("#{dir}/#{name}", content)
    end)
    {output, 0} = deps[:system].cmd("npm", ["install"], cd: dir)
  end
end
