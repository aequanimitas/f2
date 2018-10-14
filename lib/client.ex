defmodule Client do
  @moduledoc """
  Proxy for obtaining frequencies, spawn as many as you want
  """

  def start(server_pid) do
    spawn(__MODULE__, :init, [server_pid])
  end

  def init(args) do
    frequencies = []
    {server_pid, frequencies} 
    |> loop
  end

  def call(client_pid, message) do
    send(client_pid, {:request, from, message})
    receive do
      {:reply, reply} ->
        reply
    end
  end

  def reply(from, reply), do: send(from, {:reply, reply})

  def loop({server_pid, frequencies}) do
    receive do
      {:request, from, :allocate} ->

    end
  end

end
