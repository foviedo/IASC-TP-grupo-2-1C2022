defmodule ImageFinder do
  use Application

  def start(_type, _args) do
    ImageFinder.Supervisor.start_link
  end
 
  def fetch(source_file, target_directory) do
    GenServer.cast(ImageFinder.Worker, {:fetch, source_file, target_directory})
  end
end
