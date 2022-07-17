defmodule SubastasWeb.Scheduler do
  use GenServer

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
    # Here you would do whatever it is you need to do.
    # You don't have to use the state, this is only to show you can.
    # comentar las siguientes lineas, la app funca
    vencidas = Enum.filter(SubastasWeb.ColaMensaje.get_subastas, fn subasta["duracion"] -> subasta["duracion"] <= 0 end)
    if vencidas != [] do
      tag = hd vencidas["tag"]
      Enum.each(vencidas, fn subasta -> SubastasWeb.RoomChannel.handle_out_fin_subasta(subasta, tag))
    end
    Enum.each(subastas, fn subasta -> SubastasWeb.ColaMensaje.update_subasta_duracion(subasta) end)
    Logger.warn(fn -> "soy scheduler" end)
  end
end
