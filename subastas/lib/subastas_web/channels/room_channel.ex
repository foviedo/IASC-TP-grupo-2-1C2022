defmodule SubastasWeb.RoomChannel do
  use SubastasWeb, :channel

  require Logger

  @impl true
  def join("tag:" <> _private_room_id, message, socket) do
    #Logger.warn(fn -> "Subastas #{inspect(SubastasWeb.ColaMensaje.get_subastas)}" end)
    #Logger.warn(fn -> "Subastas #{inspect(SubastasWeb.ColaMensaje.get_subastas)}" end)
   # Logger.warn(fn -> "Subastas #{inspect(message)}" end)
    case message do
      ["comprador", id] ->
        comprador = Enum.filter(SubastasWeb.ColaMensaje.get_compradores, fn comprador -> comprador.id == id end)
        if(comprador == []) do
          #Map.put(socket.assigns, :user_id, id)
          #Logger.warn(fn -> "sockettt #{inspect(socket.assigns)}" end)
          SubastasWeb.ColaMensaje.add_new_comprador(%{id: id, socket: socket})
        else
          SubastasWeb.ColaMensaje.update_comprador(id, socket)
        end

        Logger.warn(fn -> "Compradores #{inspect(SubastasWeb.ColaMensaje.get_compradores)}" end)
        {:ok, SubastasWeb.ColaMensaje.get_subastas, socket}

      "vendedor" -> SubastasWeb.ColaMensaje.add_new_vendedor(socket)
                    {:ok, socket}
      _ -> {:ok, socket}
    end
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
    broadcast!(socket, "new_subastas", payload)
    Logger.warn(fn -> "Payloadd #{inspect(payload)}" end)
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_oferta", payload, socket) do
    SubastasWeb.ColaMensaje.add_new_oferta(payload)
    subasta_actualizada = SubastasWeb.ColaMensaje.update_subasta_estado(
      SubastasWeb.ColaMensaje.update_subasta_oferta(payload), "ofertada")
    broadcast!(socket, "new_oferta", subasta_actualizada)
    {:noreply, socket}
  end

  @impl true
  def handle_in("cancel_subasta", payload, socket) do
    SubastasWeb.ColaMensaje.cancelar_subasta(payload)
    broadcast!(socket, "fin_subasta", payload)
    Logger.warn(fn -> "Subastas #{inspect(SubastasWeb.ColaMensaje.get_subastas)}" end)
    {:noreply, socket}
  end

  @impl false
  def handle_out_fin_subasta(subasta) do
    subasta_terminada = SubastasWeb.ColaMensaje.update_subasta_estado(subasta, "terminada")

    #id_subasta = subasta["id"]
    #precio_ganado = subasta["precio"]

    #ofertas = Enum.filter(SubastasWeb.ColaMensaje.get_ofertas,
    #fn oferta -> oferta["id_subasta"] == id_subasta && oferta["precio"] == precio_ganado end)



    #if ofertas !=[] do
    #  oferta_ganada = hd ofertas
    #  id_comprador_ganado = oferta_ganada["id_comprador"]

     # comprador_ganado = hd (Enum.filter(SubastasWeb.ColaMensaje.get_compradores, fn comprador -> comprador["id"] == id_comprador_ganado end))


    #  push(comprador_ganado["socket"], "ganaste_subasta", subasta_terminada)

    #  broadcast!(comprador_ganado["socket"], "fin_subasta", subasta_terminada)
    #  {:noreply, comprador_ganado["socket"]}
    #else TODO falta avisar que una subasta se termino sin ganador
      comp_prueba=hd SubastasWeb.ColaMensaje.get_compradores
      Logger.warn(fn -> "comp prueba #{inspect(comp_prueba)}" end)

      Logger.warn(fn -> "Comrpador donde estas #{inspect(hd SubastasWeb.ColaMensaje.get_compradores)}" end)

      Logger.warn(fn -> "PRUEBAAAAA #{inspect(comp_prueba.socket)} subasta terminada #{inspect(subasta_terminada)}" end)

      SubastasWeb.Endpoint.broadcast("tag:fruta", "fin_subasta", subasta_terminada)
      #Logger.warn(fn -> "info #{inspect(comp_prueba.socket.assigns.user_id)}" end)
      #SubastasWeb.Endpoint.broadcast("user:#"<>comp_prueba.socket.assigns.user_id, "fin_subasta", subasta_terminada)
      #user_socket

    #end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
