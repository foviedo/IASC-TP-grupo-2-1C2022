defmodule Comprador.ColaMensaje do
  use Agent

  def start_link(arg) do
    Agent.start_link(fn -> arg end, name: __MODULE__)
  end

  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]}
    }
  end

  def value do
    Agent.get(__MODULE__, & &1)
  end

  def add(mensaje) do
    Agent.update(__MODULE__, &(&1 ++ mensaje))
  end

end
