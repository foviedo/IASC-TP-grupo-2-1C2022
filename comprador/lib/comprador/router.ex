defmodule Comprador.Router do
  use Plug.Router


  alias Comprador.{Socket, Channel, Message, ColaMensaje}

  plug Plug.Parsers,
       parsers: [:json],
       pass:  ["application/json"],
       json_decoder: Jason
  plug :match
  plug :dispatch

  get "/comprador/:id" do
    id = conn.path_params["id"]
    Channel.join(Socket, "user:" <> id)
    send_resp(conn, 200, "Registro exitoso con Id:" <> id)
  end

  get "/interes/:tag" do
    tag = conn.path_params["tag"]
    if Enum.any?(ColaMensaje.get_tags, fn t -> t.tag == tag end) do
      send_resp(conn, 400, "Ya estas registrado al tag:" <> tag)
    else
      {:ok, _response, channel} = Channel.join(Socket, "tag:" <> tag)
      Comprador.ColaMensaje.add_new_tag(channel,tag)
      send_resp(conn, 200, "Registro de interes exitoso al tag:" <> tag)
    end
  end

  get "/subastas" do
    subastas = ColaMensaje.get_subastas
    headers = [{"content-type", "json"}]
    conn_nueva = update_resp_header(
      conn,
      "content-type",
      "application/json; charset=utf-8",
      &(&1 <> "; charset=utf-8")
    )
    send_resp(conn_nueva, 200, Jason.encode!(subastas))
  end

  post "/new_oferta" do
    oferta = conn.body_params
    tags = Enum.filter(ColaMensaje.get_tags, fn t -> t.tag == oferta["tag"] end)
    if tags == [] do
      send_resp(conn, 400, "Tag:"<>oferta["tag"]<>" no registrado")
    else
      channel = (hd tags).channel

      case Enum.any?(Comprador.ColaMensaje.get_subastas, fn s -> s["tag"] == oferta["tag"] &&
        s["id"] == oferta["id_subasta"] end) do
        true -> :ok = Channel.push_async(channel, "new_oferta", oferta)
                send_resp(conn, 200, "Oferta exitosa")

        false -> send_resp(conn, 400, "Subasta Id:"<>oferta["id_subasta"]<>" tag:"<>oferta["tag"]<>" no existe")
      end
    end
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
