defmodule Comprador.Router do
  use Plug.Router


  alias Comprador.{Socket, Channel, Message}

  plug Plug.Parsers,
       parsers: [:json],
       pass:  ["application/json"],
       json_decoder: Jason
  plug :match
  plug :dispatch

  post "/buyers" do
    subasta = conn.body_params
    #la primera vez con 200, la segunda vez 500, la tercera 200...intercalando
    {:ok, _response, channel} = Channel.join(Socket, "tag:" <> "verdura")
    send_resp(conn, 200, "New subasta exitosa")
  end

  get "/subastas" do
    {:messages, subastas} = Socket.pop()
    send_resp(conn, 200, subastas)
  end

  post "/compradores" do
    comprador = conn.body_params
    {:ok, _response, channel} = Channel.join(Socket, "tag:" <> comprador["tag"])
    send_resp(conn, 200, "Registro exitoso")
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
