defmodule SubastasWeb.ColaMensaje do
  use Agent

  require Logger

  def start_link(arg) do
    Agent.start_link(fn -> arg end, name: __MODULE__)
  end

  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]}
    }
  end

  def get_subastas do
    Agent.get(__MODULE__, & Map.get(&1, :subastas))
  end

  def get_compradores do
    Agent.get(__MODULE__, & Map.get(&1, :compradores))
  end

  def get_ofertas do
    Agent.get(__MODULE__, & Map.get(&1, :ofertas))
  end

  def get_cola do
    Agent.get(__MODULE__, & &1)
  end

  def add_new_subasta(subasta) do
    Agent.update(__MODULE__, &Map.put(&1,:subastas, Map.get(&1,:subastas) ++ [subasta]))
  end


  def add_new_oferta(oferta) do
    Agent.update(__MODULE__, &Map.put(&1,:ofertas, Map.get(&1,:ofertas) ++ [oferta]))
  end

  def update_subasta_oferta(oferta) do
    subastas = Enum.filter(get_subastas, fn subasta -> subasta["id"] == oferta["id_subasta"] end)
    subasta = hd subastas
    subastas_sin_subasta = List.delete(get_subastas(), subasta)
    subasta_actualizada = Map.update!(subasta, "precio", fn precio -> oferta["precio"] end)
    subasta_actualizada_ofertada = SubastasWeb.ColaMensaje.update_subasta_estado(subasta_actualizada, "ofertada")
    Agent.update(__MODULE__,  &Map.put(&1,:subastas, subastas_sin_subasta ++ [subasta_actualizada_ofertada]))
    subasta_actualizada_ofertada
  end

  def cancelar_subasta(cancel_subasta) do
    subasta = get_subasta(cancel_subasta["id"])
    subasta_cancelada = update_subasta_estado(subasta, "cancelada")
  end

  defp get_subasta(id) do
    hd(Enum.filter(get_subastas, fn subasta -> subasta["id"] == id end))
  end

  def update_subasta_duracion(subasta) do
    subasta_actualizada = Map.update!(subasta, "duracion", fn duracion -> duracion - 1000 end)
    subastas = List.delete(get_subastas, subasta)
    Agent.update(__MODULE__,  &Map.put(&1,:subastas, subastas ++ [subasta_actualizada]))
    subasta_actualizada
  end

  def update_subasta_estado(subasta, estado) do
    subastas = List.delete(get_subastas, subasta)
    subasta_actualizada = Map.update!(subasta, "estado", fn e -> estado end)
    Agent.update(__MODULE__,  &Map.put(&1,:subastas, subastas ++ [subasta_actualizada]))
    subasta_actualizada
  end
end
