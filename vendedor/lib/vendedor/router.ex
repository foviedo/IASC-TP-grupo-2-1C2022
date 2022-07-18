defmodule Vendedor.Router do
  use Plug.Router


  alias Vendedor.{Socket, Channel, Message}

  plug Plug.Parsers,
       parsers: [:json],
       pass:  ["application/json"],
       json_decoder: Jason
  plug :match
  plug :dispatch

  post "/new_subasta" do
    subasta = conn.body_params
    #la primera vez con 200, la segunda vez 500, la tercera 200...intercalando
    {:ok, _response, channel} = Channel.join(Socket, "tag:" <> subasta["tag"], "vendedor")
    :ok = Channel.push_async(channel, "new_subasta", subasta)
    Channel.leave(channel)
    send_resp(conn, 200, "New subasta exitosa")
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
