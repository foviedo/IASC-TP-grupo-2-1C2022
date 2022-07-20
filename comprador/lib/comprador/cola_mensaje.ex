defmodule Comprador.ColaMensaje do
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

  def value do
    Agent.get(__MODULE__, & &1)
  end

  def get_subastas do
    Agent.get(__MODULE__, & Map.get(&1, :subastas))
  end

  def get_tags do
    Agent.get(__MODULE__, & Map.get(&1, :tags))
  end

  def add_new_subastas(subastas) do
    Agent.update(__MODULE__, &Map.put(&1,:subastas, Map.get(&1,:subastas) ++ subastas))
  end

  def add_new_subasta(subasta) do
    Agent.update(__MODULE__, &Map.put(&1,:subastas, Map.get(&1,:subastas) ++ [subasta]))
  end

  def add_new_tag(channel, tag_name) do
    tag = %{tag: tag_name, channel: channel}
    Agent.update(__MODULE__, &Map.put(&1,:tags, Map.get(&1,:tags) ++ [tag]))
  end

  def add_mi_oferta(oferta) do
    ofertas = & &1.ofertas ++ [oferta]
    Agent.update(__MODULE__, &(Map.replace!(&1, :ofertas, ofertas)))
  end

  def add_new_subasta_ofertada(oferta) do
    Agent.update(__MODULE__, &Map.put(&1,:subastas, Map.get(&1,:subastas) ++ [oferta]))
  end

  def update_subasta(subasta) do
    s = Enum.filter(get_subastas, fn subs -> subs["id"] == subasta["id"] end)
    sub = hd s
    subasta_sin_sub = List.delete(get_subastas, sub)
    Logger.warn(fn -> "subastassssss actuales #{inspect(subasta_sin_sub)}" end)

    subast = Map.update!(sub, "precio", fn precio -> subasta["precio"] end)
    subasta_actualizada = Map.update!(subast, "estado", fn estado -> subasta["estado"] end)

    Agent.update(__MODULE__, &Map.put(&1,:subastas, subasta_sin_sub ++ [subasta_actualizada]))
  end

  def update_subasta_gane(subasta) do
    s = Enum.filter(get_subastas, fn subs -> subs["id"] == subasta["id"] end)
    sub = hd s
    subasta_sin_sub = List.delete(get_subastas, s)

    subast = Map.update!(sub, "precio", fn precio -> subasta["precio"] end)
    subasta_actualizada = Map.update!(subast, "estado", fn estado -> "gane" end)
    Agent.update(__MODULE__, &Map.put(&1,:subastas, subasta_sin_sub ++ [subasta_actualizada]))
  end

end
