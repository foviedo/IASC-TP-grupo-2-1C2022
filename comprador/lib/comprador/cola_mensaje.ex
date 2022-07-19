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

  def get_subastas do
    Agent.get(__MODULE__, & Map.get(&1, :subastas))
  end

  def add(mensaje) do
    Agent.update(__MODULE__, &(&1 ++ mensaje))
  end

  def add_new_subasta(subasta) do
    Agent.update(__MODULE__, &Map.put(&1,:subastas, Map.get(&1,:subastas) ++ subasta))
  end

  def add_mi_oferta(oferta) do
    #TODO
    ofertas = & &1.ofertas ++ [oferta]
    Agent.update(__MODULE__, &(Map.replace!(&1, :ofertas, ofertas)))
  end

  def add_new_subasta_ofertada(oferta) do
    Agent.update(__MODULE__, &Map.put(&1,:subastas, Map.get(&1,:subastas) ++ oferta))
  end

  def update_subasta(subasta) do
    s = Enum.filter(get_subastas, fn subs -> subs["id"] == subasta["id"] end)
    sub = hd s
    subast = Map.update!(sub, "precio", fn precio -> subasta["precio"] end)
    subasta_actualizada = Map.update!(subast, "estado", fn estado -> subasta["estado"] end)
    List.delete(get_subastas, s)
    Agent.update(__MODULE__, &Map.put(&1,:subastas, Map.get(&1,:subastas) ++ [subasta_actualizada]))
  end

  def update_subasta_gane(subasta) do
    s = Enum.filter(get_subastas, fn subs -> subs["id"] == subasta["id"] end)
    sub = hd s
    subast = Map.update!(sub, "precio", fn precio -> subasta["precio"] end)
    subasta_actualizada = Map.update!(subast, "estado", fn estado -> "gane" end)
    List.delete(get_subastas, s)
    Agent.update(__MODULE__, &Map.put(&1,:subastas, Map.get(&1,:subastas) ++ [subasta_actualizada]))
  end

  def remove_subasta(subasta) do
    #buscar la subasta con el id de la subasta que llega subasta["id"], y despues borrarla de la lista &1[:subastas]
    #subasta = XXXXX
    #subastas = Lista.delete(get_subastas, subasta)
    #Agent.update(__MODULE__,  &Map.put(&1,:subastas, subastas))
  end

end
