use Mix.Config

config :tiny_svc_core,
  strategy: TinySvcLocal,
  root_host: "tinysvc.dev",
  port: 4001

config :porcelain, driver: Porcelain.Driver.Basic
