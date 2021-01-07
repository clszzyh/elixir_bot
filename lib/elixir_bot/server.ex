defmodule ElixirBot.Server do
  @moduledoc """
  Server
  """

  alias ElixirBot.Context
  use GenServer, restart: :temporary

  def start_link(o) do
    GenServer.start_link(__MODULE__, o, name: __MODULE__)
  end

  def next, do: GenServer.cast(__MODULE__, :next)

  @impl true
  def init(o) do
    case Context.init(o) do
      {:ok, _} = res -> res
      {:error, _} -> :ignore
    end
  end

  @impl true
  def handle_cast(:next, state) do
    case Context.next(state) do
      {:ok, state} -> {:noreply, state}
      {:error, reason} -> {:stop, reason, state}
    end
  end

  @impl true
  def terminate(reason, state) do
    IO.puts(inspect({:terminate, reason}))
    Context.cleanup(reason, state)
  end
end
