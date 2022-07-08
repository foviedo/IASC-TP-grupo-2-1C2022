defmodule ImageFinder.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [worker(ImageFinder.Worker, [ImageFinder.Worker]),
                worker(ImageFinder.Saver, [ImageFinder.Saver]),
               # worker(ImageFinder.HttpFetcher, [ImageFinder.HttpFetcher]),
               worker(ImageFinder.DynamicHttpSupervisor,[ImageFinder.DynamicHttpSupervisor])]

    supervise(children, strategy: :one_for_one)
  end
end
