defmodule Comprador do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do

    dispatch = :cowboy_router.compile([
      {:_, [{"/", Comprador.TopPageHandler, []}]}
    ])
    {:ok, _} = :cowboy.start_http(:http, 100,
                       [port: 8080],
                       [env: [dispatch: dispatch]])

    # List all child processes to be supervised
    children = [
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
