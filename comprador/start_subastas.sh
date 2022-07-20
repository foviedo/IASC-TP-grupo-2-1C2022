#!/bin/bash
iex --name compradorA@127.0.0.1 -S mix ;
{:ok, socket} = Comprador.Socket.start_link([url: "ws://localhost:4000/socket/websocket"])
{:ok, _response, channel} = Comprador.Channel.join(socket, "tag:fruta",[“comprador”,1])