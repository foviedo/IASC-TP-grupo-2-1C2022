defmodule SubastasWeb.Scheduler do
  use GenServer

  require  SubastasWeb.ColaMensaje

  require Logger

  @impl true
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  @impl true
  def init(state) do
    :timer.send_interval(1000, :work)
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    do_recurrent_thing(state)
    {:noreply, state}
  end

  defp do_recurrent_thing(state) do
    subastas = SubastasWeb.ColaMensaje.get_subastas()

    vencidas = Enum.filter(subastas, fn subasta -> subasta["duracion"] <= 0 end)

    vencidas_no_terminadas_ganadas = Enum.filter(vencidas, fn subasta -> subasta["estado"] != "terminada" &&  subasta["estado"] != "ganada" subasta["estado"] != "cancelada" end)
    #Logger.warn(fn -> "message #{inspect(vencidas_no_terminadas_ganadas)}" end)
    if vencidas_no_terminadas_ganadas != [] do
      Enum.each(vencidas_no_terminadas_ganadas, fn subasta -> SubastasWeb.RoomChannel.handle_out_fin_subasta(subasta) end)
    end
    no_terminadas = Enum.filter(SubastasWeb.ColaMensaje.get_subastas(), fn subasta -> subasta["estado"] != "terminada" end)
    Enum.each(no_terminadas, fn subasta -> SubastasWeb.ColaMensaje.update_subasta_duracion(subasta) end)
  end
end
