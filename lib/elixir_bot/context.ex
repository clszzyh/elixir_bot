defmodule ElixirBot.Context do
  @moduledoc """
  Server
  """

  alias Action.Github
  alias ElixirBot.Event

  @type reason :: term()
  @type stage :: :parse | :before | :process
  @type result :: {:ok, t()} | {:error, reason}

  @type t :: %__MODULE__{
          github: Github.t(),
          stage: stage() | nil,
          id: number() | nil,
          number: number() | nil,
          body: binary() | nil,
          state: atom() | nil,
          result: term()
        }

  @enforce_keys [:github]
  defstruct @enforce_keys ++ [:stage, :id, :body, :number, :state, :result]

  @spec init(binary | nil) :: result()
  def init(o) do
    case Github.init(o) do
      {:ok, github} ->
        {:ok, %__MODULE__{github: github}}

      {:error, reason} ->
        IO.puts(inspect({o, reason}))
        {:error, reason}
    end
  end

  @module_map %{
    "issue_comment" => Event.IssueComment,
    "issues" => Event.Issue
  }

  @spec next(t()) :: result()
  def next(%{github: %{event_name: event_name}} = ctx)
      when is_map_key(@module_map, event_name) do
    module = @module_map[event_name]

    Enum.reduce_while(Event.stages(), {:ok, ctx}, fn stage, {:ok, ctx} ->
      case Event.process(stage, module, ctx) do
        {:ok, ctx} -> {:cont, {:ok, ctx}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  def next(_), do: {:error, :ignored}

  defimpl Inspect do
    def inspect(%{state: state, result: result, stage: stage, id: id}, _opts) do
      id_str = if id, do: "<#{id}> ", else: ""
      "[#{stage}] #{id_str}{#{state}} #{inspect(result)}"
    end
  end

  @spec cleanup(reason, t()) :: :ok
  def cleanup(reason, ctx) do
    IO.puts(inspect({reason, ctx}))
  end
end
