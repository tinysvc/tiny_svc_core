defmodule TinySvc.ServiceManager do
  @services_dir "services"
  alias TinySvc.Service

  def find(service_name) do
    case File.exists?("#{@services_dir}/#{service_name}") do
      true ->
        %Service{name: service_name}
      false -> raise "Service #{service_name} not found!"
    end
  end
end
