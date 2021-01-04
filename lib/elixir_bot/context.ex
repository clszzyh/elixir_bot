defmodule ElixirBot.Context do
  @moduledoc """
  Server
  """

  alias Action.Github
  alias ElixirBot.Event
  alias ElixirBot.Markdown
  alias ElixirBot.Report
  alias ElixirBot.Util
  require Logger

  @type reason :: term()
  @type stage :: :wait | :parse | :before | :process
  @type error_result :: {:error, reason} | {:error, reason, t()}
  @type result :: {:ok, t()} | error_result

  @stages Enum.with_index([:wait, :parse, :before, :process])
  @stage_map for {x, i} <- @stages, {y, j} <- @stages, i + 1 == j, do: {x, y}, into: %{}

  @type t :: %__MODULE__{
          github: Github.t(),
          stage: stage(),
          id: number() | nil,
          number: number() | nil,
          markdown: Markdown.t() | nil,
          state: atom() | nil,
          result: term()
        }

  @enforce_keys [:github]
  defstruct @enforce_keys ++ [:id, :markdown, :number, :state, :result, stage: :wait]

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

  @module_map for m <- [Event.IssueComment, Event.Issue], do: {m.name(), m}, into: %{}

  @spec next(t()) :: result() | {:stop, t()}
  def next(%{github: %{event_name: event_name}} = ctx)
      when is_map_key(@module_map, event_name) do
    next_inner(ctx, @module_map[event_name])
  end

  def next(_) do
    {:error, :next_ignored}
  end

  defp next_inner(%{stage: stage} = ctx, module) when is_map_key(@stage_map, stage) do
    Logger.warn("[next] #{stage}")
    Event.process(@stage_map[stage], module, ctx)
  end

  defp next_inner(%{stage: stage} = ctx, _) do
    Logger.warn("[stop] #{stage}")
    {:stop, ctx}
  end

  @spec cleanup(reason, t()) :: :ok
  def cleanup({kind, message}, %{github: github, number: number})
      when kind in [:error, :exit, :throw] do
    number_str = if number, do: "##{number}", else: ""
    body = number_str <> Util.elixir_code_block(message, :elixir)

    :ok = Report.issue(github, message |> String.split("\n") |> List.first(), body, ["bug"])
  end

  def cleanup(_reason, _ctx), do: :ok

  defimpl Inspect do
    def inspect(%{state: state, result: result, stage: stage, id: id}, _opts) do
      id_str = if id, do: "<#{id}> ", else: ""
      "[#{stage}] #{id_str}{#{state}} #{inspect(result)}"
    end
  end
end
