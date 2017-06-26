#defmodule TinyFaas.LocalRequestServer do
  #use GenServer
  #require Logger

  #def start_link do
    #GenServer.start_link(__MODULE__, [], name: __MODULE__)
  #end

  #def init(_state) do
    #Application.ensure_all_started(:chumak)
    #{:ok, socket} = :chumak.socket(:pub)
    #case :chumak.bind(socket, :tcp, '127.0.0.1', 3000) do
      #{:ok, _pid} -> :ok
      #{:error, reason} ->
        #Logger.error("Connection failed: #{inspect reason}")
      #reply ->
        #Logger.info("Unhandled reply for connect: #{inspect reply}")
    #end
    #{:ok, socket}
  #end

  #def handle_call(:test, _from, socket) do
    #:chumak.send(socket, 'test testing')
    #case :chumak.send(socket, ' message') do
      #:ok ->
        #Logger.info("message published")
      #{:error, reason} ->
        #Logger.error("Publish failed: #{inspect reason}")
    #end

    #{:reply, nil, socket}
  #end

  #def test do
    #GenServer.call(__MODULE__, :test)
  #end
#end

