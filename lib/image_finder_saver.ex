defmodule ImageFinder.Saver do
    use GenServer
  
    def start_link(name) do
      GenServer.start_link(__MODULE__, :ok, name: name)
    end
  
    def init(:ok) do
      {:ok, %{}}
    end
  
    def handle_cast({:save, body, directory}, state) do
      IO.puts "estoy en saver"
      save(body,directory)
      {:noreply, state}
    end
  
    def save(body, directory) do
      File.write! "#{directory}/#{digest(body)}", body
    end
  
    def digest(body) do
      :crypto.hash(:md5 , body) |> Base.encode16()
    end
  end
  