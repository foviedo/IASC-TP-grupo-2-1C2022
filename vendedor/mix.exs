defmodule Vendedor.Mixfile do
  use Mix.Project

  def project do
    [
      app: :Vendedor,
      version: "0.11.1",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      docs: [extras: ["README.md"], main: "readme"],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :ssl],
      mod: {Vendedor, []}
    ]
  end

  defp deps do
    [
      {:websocket_client, "~> 1.3"},
      {:jason, "~> 1.0", optional: true},
      {:phoenix, github: "phoenixframework/phoenix", tag: "v1.5.1", only: :test},
      {:plug_cowboy, "~> 2.0"},
      {:ex_doc, "~> 0.18", only: :dev},
      {:libcluster, "~> 3.3"},
      {:horde, "~> 0.8.7"}
    ]
  end

  defp description do
    """
    Connect to Phoenix Channels from Elixir
    """
  end
end
