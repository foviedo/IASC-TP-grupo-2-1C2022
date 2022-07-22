defmodule Subastas.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do

    topologies = [
      example: [
        #strategy: Cluster.Strategy.Epmd,
        strategy: Elixir.Cluster.Strategy.LocalEpmd
        #config: [hosts: [:"vendedor@127.0.0.1",:"compradorA@127.0.0.1" ]],
      ]
    ]

    children = [
      {SubastasWeb.ColaMensaje, %{subastas: [], vendedores: [], compradores: [], ofertas: []}},
      {Horde.Registry, [name: Subastas.HordeRegistry, keys: :unique]},
      {Horde.DynamicSupervisor, [name: Subastas.HordeSupervisor, strategy: :one_for_one]},
      {Cluster.Supervisor, [topologies, [name: Subastas.ClusterSupervisor]]},
      # Start the Telemetry supervisor
      SubastasWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Subastas.PubSub},
      # Start the Endpoint (http/https)
      SubastasWeb.Endpoint,
      {SubastasWeb.Scheduler, %{}}

      # Start a worker by calling: Subastas.Worker.start_link(arg)
      # {Subastas.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options

    opts = [strategy: :one_for_one, name: Subastas.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SubastasWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
