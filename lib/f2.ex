defmodule F2 do

  require Logger

  def start do
    pid = spawn(__MODULE__, :init, [])
    {pid |> Process.register(__MODULE__), pid}
  end

  def stop, do: call(:stop)

  def init do
    Process.flag(:trap_exit, true)
    allocated = []

    {predef_frequencies, allocated}
    |> loop
  end

  def allocate, do: call(:allocate)
  def deallocate(freq), do: call({:deallocate, freq})

  defp predef_frequencies, do: 10..15 |> Enum.to_list

  ## GEN
  def call(message) do
    send(__MODULE__, {:request, self(), message})
    receive do
      {:reply, reply} -> reply
    end
  end

  def reply(from, reply), do: send(from, {:reply, reply})

  def loop(frequencies) do
    receive do
      {:request, from, message} ->
        {new_frequencies, reply} = handle_msg(from, message, frequencies)
        {:allocate, from, frequencies}
        reply(from, reply)
        loop(new_frequencies)
      {:EXIT, pid, _reason} ->
        :io.format("a client is dying: ~p~n", [pid])
        {frequencies, allocated} = exited(pid, frequencies)
        loop({frequencies, allocated})
    end
  end

  ## internal
  @doc """
  When a frequency has been allocated and the client process dies, the server dies too.
  """
  def handle_msg(from, :allocate, {[], allocated} = f), do: {f, {:error, :all_allocated}}
  def handle_msg(from, :allocate, {[f | freq], allocated}) do
    Process.link(from)
    {{freq, [{from, f} | allocated]}, {:ok, f}}
  end

  def handle_msg(_from, {:deallocate, _f}, {freqs, []}) do
    {{freqs, []}, {:error, :nothing_allocated}}
  end

  def handle_msg(from, {:deallocate, f}, {freqs, allocated}) do
    case List.keyfind(allocated, from, 0) do
      {^from, ^f} ->
        Process.unlink(from)
        {{[f | freqs], List.keydelete(allocated, from, 0)}, {:ok, :deallocate}}
      nil ->
        {allocated, {:error, :not_client}}
    end
  end

  def exited(pid, {frequencies, allocated}) do
    case List.keyfind(allocated, pid, 0) do
      nil ->
        {frequencies, allocated}
      {^pid, value} ->
        new_allocated = List.keydelete(allocated, pid, 0)
        {[value | frequencies], new_allocated}
    end
  end
end
