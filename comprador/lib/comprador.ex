defmodule Comprador do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      #{Comprador.ColaMensaje, %{:new_subastas => [], :subastas_ofertadas => [], :mis_ofertas => []}},
      {Comprador.ColaMensaje, []},
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
