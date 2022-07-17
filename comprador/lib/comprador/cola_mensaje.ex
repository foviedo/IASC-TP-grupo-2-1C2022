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
    Agent.update(__MODULE__, &Map.put(&1,:subastas, Map.get(&1,:subastas) ++ [subasta]))
  end

  def add_mi_oferta(oferta) do
    ofertas = & &1.ofertas ++ [oferta]
    Agent.update(__MODULE__, &(Map.replace!(&1, :ofertas, ofertas)))
    update_subasta(oferta)
  end

  def add_new_subasta_ofertada(comprador) do
    compradores = & &1.compradores ++ [comprador]
    Agent.update(__MODULE__, &(&1
    |> Enum.map(fn
      :compradores-> compradores
      other -> other
    end)))
  end

  def add_new_vendedor(vendedor) do
    vendedores = & &1.vendedores ++ [vendedor]
    Agent.update(__MODULE__, &(&1
    |> Enum.map(fn
      :vendedores -> vendedores
      other -> other
    end)))
  end

  def update_subasta(oferta) do
    subasta = Enum.filter(& &1.subastas, fn s -> s["id"] == oferta["id_subasta"] end)
    subasta_actualizada = Map.replace!(subasta,"precio", oferta["precio"])
    & &1.subastas -- [subasta]
    & &1.subastas ++ [subasta_actualizada]
    {:ok, subasta_actualizada}
  end

end
