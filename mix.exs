defmodule TinySvcCore.Mixfile do
  use Mix.Project

  def project do
    [app: :tiny_svc_core,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]

  end

  def application do
    [
      mod: {TinySvcCore, []},
      extra_applications: [:logger, :cowboy, :plug, :porcelain, :exprotobuf, :uuid]
    ]
  end

  defp deps do
    [
      {:exprotobuf, "~> 1.2"},
      {:plug, "~> 1.3.5"},
      {:cowboy, "~> 1.0"},
      {:poison, "~> 2.0"},
      {:uuid, "~> 1.1"},
      {:porcelain, "~> 2.0"},
      {:ex_aws, "~> 1.0"},
      {:double, "~> 0.6.0", only: :test},
    ]
  end
end
