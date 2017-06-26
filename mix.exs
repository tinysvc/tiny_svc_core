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

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      mod: {TinySvcCore, []},
      extra_applications: [:logger, :cowboy, :plug, :porcelain, :exprotobuf, :uuid]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:my_app, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:exprotobuf, "~> 1.2"},
      {:plug, "~> 1.3.5"},
      {:cowboy, "~> 1.0"},
      {:poison, "~> 2.0"},
      {:uuid, "~> 1.1"},
      {:porcelain, "~> 2.0"},
      {:double, "~> 0.6.0", only: :test},
    ]
  end
end
