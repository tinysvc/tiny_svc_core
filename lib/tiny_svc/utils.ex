defmodule TinySvc.Utils do
  @deps [file: File]

  def write_template(dir, template, params, deps \\ @deps)
  def write_template(dir, {app_name, template_name}, params, deps) do
    priv_dir = :code.priv_dir(app_name) |> to_string
    template = Path.join([priv_dir, "templates", "#{template_name}.eex"])
    content = EEx.eval_file(template, params)
    deps[:file].write!("#{dir}/#{template_name}", content)
  end
  def write_template(dir, template_name, params, deps) do
    write_template(dir, {:tiny_svc_core, template_name}, params, deps)
  end
end
