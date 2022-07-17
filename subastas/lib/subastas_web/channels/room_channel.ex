defmodule SubastasWeb.RoomChannel do
  use SubastasWeb, :channel

  alias SubastasWeb.{ColaMensaje}

  require Logger


  @impl true
  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  #def join("room:lobby", _message, socket) do
    #{:ok, socket}
  #end

  #def join("room:" <> _private_room_id, _params, _socket) do
  #  {:error, %{reason: "unauthorized"}}
  #end

  #habria que reenviar los msj antiguos cada vez que se suscribe un nuevo cliente
  def join("tag:" <> _private_room_id, message, socket) do
    Logger.warn(fn -> "Subastas #{inspect(SubastasWeb.ColaMensaje.get_subastas)}" end)
    case message do
      "comprador" -> SubastasWeb.ColaMensaje.add_new_comprador(socket)
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

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast!(socket, "shout", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_subasta", payload, socket) do
    SubastasWeb.ColaMensaje.add_new_subasta(payload)
    broadcast!(socket, "new_subastas", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_oferta", payload, socket) do
    {:ok, subasta_actualizada} = SubastasWeb.ColaMensaje.add_new_oferta(payload)
    broadcast!(socket, "new_oferta", subasta_actualizada)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
