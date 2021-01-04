defmodule ElixirBot.Server do
  @moduledoc """
  Server
  """

  alias ElixirBot.Context
  use GenServer, restart: :temporary

  require Logger

  def start_link(o) do
    GenServer.start_link(__MODULE__, o, name: __MODULE__)
  end

  def next, do: GenServer.call(__MODULE__, :next)

  @impl true
  def init(o) do
    case Context.init(o) do
      {:ok, _} = res -> res
      {:error, _} -> :ignore
    end
  end

  @impl true
  def handle_call(:next, from, state) do
    :ok = ping(from)
    {:noreply, state}
  end

  @impl true
  def handle_info({:next, from}, state) do
    case Context.next(state) do
      {:ok, state} ->
        :ok = ping(from)
        {:noreply, state}

      {:stop, state} ->
        :ok = GenServer.reply(from, :ok)
        {:noreply, state}

      {:error, reason} ->
        {:stop, {:reply, from, reason}, state}

      {:error, reason, state} ->
        {:stop, {:reply, from, reason}, state}
    end
  end

  @impl true
  def terminate({:reply, from, reason}, state) do
    IO.puts(inspect({:terminate_and_reply, reason}))
    Context.cleanup(reason, state)
    :ok = GenServer.reply(from, :ok)
  end

  def terminate(reason, state) do
    IO.puts(inspect({:terminate, reason}))
    Context.cleanup(reason, state)
  end

  defp ping(from), do: Process.send(self(), {:next, from}, [])
end
