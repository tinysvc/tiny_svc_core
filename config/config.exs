use Mix.Config

config :tiny_svc_core,
  root_host: "tinysvc.dev",
  function_handler: TinySvcLocal.FunctionHandler,
  port: 4001

config :porcelain, driver: Porcelain.Driver.Basic
