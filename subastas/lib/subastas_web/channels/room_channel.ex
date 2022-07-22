defmodule SubastasWeb.RoomChannel do
  use SubastasWeb, :channel


  require Logger

  @impl true
  def join("tag:" <> _private_room_id, message, socket) do
    subastas = Enum.filter(SubastasWeb.ColaMensaje.get_subastas, fn s -> s["tag"] == _private_room_id end)
    {:ok, subastas, socket}
  end

  @impl true
  def join("user:" <> _private_room_id, message, socket) do
    {:ok, [], socket}
  end
  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload <> "osahouisfhuioahfssdasdioasfhio"}, socket}
  end


  @impl true
  def handle_in("new_subasta", payload, socket) do
    SubastasWeb.ColaMensaje.add_new_subasta(payload)
    broadcast!(socket, "new_subasta", payload)
    Logger.warn(fn -> "Subasta nueva #{inspect(payload)}" end)
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_oferta", payload, socket) do
    SubastasWeb.ColaMensaje.add_new_oferta(payload)
    subasta_actualizada = SubastasWeb.ColaMensaje.update_subasta_oferta(payload)
    Logger.warn(fn -> "Subasta ofertada #{inspect(subasta_actualizada)}" end)
    broadcast!(socket, "new_oferta", subasta_actualizada)
    {:noreply, socket}
  end

  @impl true
  def handle_in("cancel_subasta", payload, socket) do
    subasta_cancelada = SubastasWeb.ColaMensaje.cancelar_subasta(payload)
    Logger.warn(fn -> "Subasta cancelada #{inspect(subasta_cancelada)}" end)
    broadcast!(socket, "fin_subasta", subasta_cancelada)
    {:noreply, socket}
  end

  @impl false
  def handle_out_fin_subasta(subasta) do
    subasta_terminada = SubastasWeb.ColaMensaje.update_subasta_estado(subasta, "terminada")

    id_subasta = subasta["id"]
    precio_ganado = subasta["precio"]

    ofertas = Enum.filter(SubastasWeb.ColaMensaje.get_ofertas,
    fn oferta -> oferta["id_subasta"] == id_subasta && oferta["precio"] == precio_ganado end)
    Logger.warn(fn -> "ofertas #{inspect(ofertas)}" end)

    if ofertas !=[] do
      oferta_ganada = hd ofertas
      id_comprador_ganado = oferta_ganada["id_comprador"]
      SubastasWeb.Endpoint.broadcast("tag:"<>subasta["tag"], "fin_subasta", subasta_terminada)
      subasta_ganada = SubastasWeb.ColaMensaje.update_subasta_estado(subasta, "ganada")
      SubastasWeb.Endpoint.broadcast("user:"<>id_comprador_ganado, "ganaste_subasta", subasta_ganada)
      {:noreply,id_comprador_ganado }
    else
      SubastasWeb.Endpoint.broadcast("tag:"<>subasta["tag"], "fin_subasta", subasta_terminada)
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
