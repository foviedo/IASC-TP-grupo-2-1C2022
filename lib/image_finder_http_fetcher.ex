defmodule ImageFinder.HttpFetcher do
    use GenServer
  
    def start_link(name) do
      GenServer.start_link(__MODULE__, :ok, name: name)
    end
  
    def init(:ok) do
      {:ok, %{}}
    end
  
    def handle_cast({:get, link,target_directory}, state) do
      IO.puts "estoy en fetcher, link: #{link}"
      fetch_link(link,target_directory)
      {:noreply, state}
    end
  
    def fetch_link(link, target_directory) do
      HTTPotion.get(link,timeout: 200_000).body  |> save(target_directory)
    end
  
    def save(body, directory) do
      GenServer.cast(ImageFinder.Saver, {:save, body,directory})
    end
  
  end
  