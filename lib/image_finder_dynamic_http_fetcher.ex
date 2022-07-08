defmodule ImageFinder.DynamicHttpFetcher do
    #use GenServer
    use Task

   # def start_link(name,{link,target_directory}) do
   #   GenServer.start_link(__MODULE__, {link,target_directory}, name: name)
   # end

   def start_link({link,target_directory}) do
    Task.start_link(__MODULE__, :init, [{link,target_directory}])
   end

    def child_spec({name, {link,target_directory}}) do
        %{id: name, start: {__MODULE__, :start_link, [name, {link,target_directory}]}, type: :worker}
    end
  
    def init({link,target_directory}) do
        #llamar a fetch_link
        fetch_link(link,target_directory)
      {:ok, %{}}
    end
  
  #  def handle_cast({:get, link,target_directory}, state) do
  #    IO.puts "estoy en fetcher, link: #{link}"
  #    fetch_link(link,target_directory)
  #    {:noreply, state}
  #  end
  
    def fetch_link(link, target_directory) do
      HTTPotion.get(link,timeout: 200_000).body  |> save(target_directory)
    end
  
    def save(body, directory) do
      GenServer.cast(ImageFinder.Saver, {:save, body,directory})
    end
  
  end
  