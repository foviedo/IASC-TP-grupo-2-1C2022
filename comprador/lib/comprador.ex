defmodule Comprador do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do

    socket_opts = [
      url: "ws://localhost:4000/socket/websocket"
    ]

    # List all child processes to be supervised
    children = [
    #  {Plug.Cowboy, scheme: :http, plug: Comprador.Router, options: [port: 8081]},
      #{Comprador.Socket, {socket_opts, name: Comprador.Socket}},
      {Comprador.ColaMensaje, %{:subastas => [], :mis_ofertas => []}},
      #{Comprador.ColaMensaje, []},
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
