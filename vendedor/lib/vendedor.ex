defmodule Vendedor do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do

    socket_opts = [
      url: "ws://localhost:4000/socket/websocket"
    ]

    topologies = [
      example: [
        #strategy: Cluster.Strategy.Epmd,
        strategy: Elixir.Cluster.Strategy.LocalEpmd
        #config: [hosts: [:"subastas@127.0.0.1"]],
      ]
    ]
    # List all child processes to be supervised
    children = [
      {Vendedor.Socket, {socket_opts, name: Vendedor.Socket}},
      {Plug.Cowboy, scheme: :http, plug: Vendedor.Router, options: [port: 8080]},
      {Horde.Registry, [name: Vendedor.Registry, keys: :unique]},
      {Horde.DynamicSupervisor, [name: Vendedor.DistributedSupervisor, strategy: :one_for_one]},
      {Cluster.Supervisor, [topologies, [name: Vendedor.ClusterSupervisor]]},
      # Starts a worker by calling: Vendedor.Worker.start_link(arg)
      # {Vendedor.Worker, arg}
      Vendedor.ChannelSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Vendedor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
