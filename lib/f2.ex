defmodule F2 do
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
        {:allocate, from, frequencies})
        reply(from, reply)
        loop(new_frequencies)
      {:EXIT, pid, _reason} ->
    end
  end

  ## internal
  @doc """
  Links client. If server dies does the client die?
  """
  def handle_msg(from, :allocate, {[], allocated}} = f), do: {f, {:error, :all_allocated}}
  def handle_msg(from, :allocate, {[f | freq], allocated}}) do
    Process.link(from)
    {{freq, [{f, from} | allocated]}, {:ok, f}}
  end

  def handle_msg(from, {:deallocate, f}, {freqs, allocated}}) do
    case List.keymember?(allocated, pid, 0) do
      {^from, ^f} ->
        Process.unlink(pid)
        {{[f | freqs], List.keydelete(allocated, pid, 0)}, {:ok, :deallocate}}
      nil ->
        {allocated, {:error, :not_client}}
    end
  end

  def allocate
  def deallocate

  defmodule Client do
    @moduledoc "Proxy for obtaining frequencies, spawn as many as you want"
  end
end
