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

  def add_subasta_terminada(subasta) do
    Agent.update(__MODULE__, &Map.put(&1,:subastas_terminadas, Map.get(&1,:subastas_terminadas) ++ [subasta]))
  end

  def add_new_oferta(oferta) do
    ofertas = & &1.ofertas ++ [oferta]
    Agent.update(__MODULE__, &(Map.replace!(&1, :ofertas, ofertas)))
  end

  def add_new_comprador(comprador) do
    Agent.update(__MODULE__, &Map.put(&1,:compradores, Map.get(&1,:compradores) ++ [comprador]))
  end

  def update_comprador(id,socket_nuevo) do
    Agent.update(__MODULE__,  &Map.put(&1,:compradores, update_comprador(Map.get(&1,:compradores), id, socket_nuevo)))
  end

  def add_new_vendedor(vendedor) do
    Agent.update(__MODULE__, &Map.put(&1,:vendedores, Map.get(&1,:vendedores) ++ [vendedor]))
  end

  def update_comprador(compradores, id, socket_nuevo) do
    c = Enum.filter(compradores, fn comprador -> comprador.id == id end)
    comprador = hd c
    comprador_actualizado = Map.update!(comprador, :socket, fn socket -> socket_nuevo end)
    compradores = List.delete(compradores, comprador)
    compradores ++ [comprador_actualizado]
  end

  def update_subasta_oferta(oferta) do
    subastas = Enum.filter(get_subastas, fn subasta -> subasta["id"] == oferta["id_subasta"] end)
    subasta = hd subastas
    subasta_actualizada = Map.update!(subasta, "precio", fn precio -> oferta["precio"] end)
    subastas_actuales = get_subastas()
    subastas = List.delete(subastas_actuales, subasta)
    Agent.update(__MODULE__,  &Map.put(&1,:subastas, subastas ++ [subasta_actualizada]))
    subasta_actualizada
  end

  def cancelar_subasta(id) do
    subasta = get_subasta(id)
    update_subasta_estado(subasta, "cancelado")
  end

  defp get_subasta(id) do
    hd(Enum.filter(get_subastas, fn subasta -> subasta["id"] == id end))
  end

  def update_subasta_duracion(subasta) do
    subasta_actualizada = Map.update!(subasta, "duracion", fn duracion -> duracion - 1000 end)
    subastas = List.delete(get_subastas, subasta)
    Agent.update(__MODULE__,  &Map.put(&1,:subastas, subastas ++ [subasta_actualizada]))
  end

  def update_subasta_estado(subasta, estado) do
    subastas = List.delete(get_subastas, subasta)
    subasta_actualizada = Map.update!(subasta, "estado", fn e -> estado end)
    Agent.update(__MODULE__,  &Map.put(&1,:subastas, subastas ++ [subasta_actualizada]))
    subasta_actualizada
  end

  def remove_subasta(subasta) do
    subastas = List.delete(get_subastas, subasta)
    Agent.update(__MODULE__,  &Map.put(&1,:subastas, subastas))
  end
end
