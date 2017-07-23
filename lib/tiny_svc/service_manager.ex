defmodule TinySvc.ServiceManager do
  @services_dir "services"
  alias TinySvc.Service

  @deps [file: File]

  def find(service_name, deps \\ @deps) do
    case deps[:file].exists?("#{@services_dir}/#{service_name}") do
      true ->
        %Service{name: service_name}
      false -> nil
    end
  end
end
