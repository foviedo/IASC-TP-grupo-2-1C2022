defmodule Comprador do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    socket_opts = [
      url: "ws://localhost:4000/socket/websocket"
    ]

    port = String.to_integer(System.get_env("PORT") || "8081")
    topologies = [
      example: [
        #strategy: Cluster.Strategy.Epmd,
        strategy: Elixir.Cluster.Strategy.LocalEpmd
        #config: [hosts: [:"subastas@127.0.0.1"]],
      ]
    ]

    # List all child processes to be supervised
    children = [
      {Plug.Cowboy, scheme: :http, plug: Comprador.Router, options: [port: port]},
      {Comprador.Socket, {socket_opts, name: Comprador.Socket}},
      {Comprador.ColaMensaje, %{subastas: [], mis_ofertas: [], tags: []}},
      {Horde.Registry, [name: Comprador.Registry, keys: :unique]},
      {Horde.DynamicSupervisor, [name: Comprador.DistributedSupervisor, strategy: :one_for_one]},
      {Cluster.Supervisor, [topologies, [name: Comprador.ClusterSupervisor]]},
      # Starts a worker by calling: Comprador.Worker.start_link(arg)
      # {Comprador.Worker, arg}
      Comprador.ChannelSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Comprador.Supervisor]
    Supervisor.start_link(children, opts)


  end
end
