defmodule Vendedor.Router do
  use Plug.Router

  alias Vendedor.{Socket, Channel, Message}

  plug :match
  plug :dispatch

  get "/subastas" do
    {:ok, _response, channel} = Channel.join(Socket, "room:lobby")
    {:ok, message} = Channel.push(channel, "ping", "for test+++++")
    send_resp(conn, 200, message)
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
