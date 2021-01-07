defmodule ElixirBot.Context do
  @moduledoc """
  Server
  """

  alias Action.Github
  alias ElixirBot.Event
  require Logger

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

  @stages [:parse, :before, :process]
  @module_map %{
    "issue_comment" => Event.IssueComment,
    "issues" => Event.Issue
  }

  @spec next(t()) :: result()
  def next(%{github: %{event_name: event_name}} = ctx) when is_map_key(@module_map, event_name) do
    next_reduce(ctx, @module_map[event_name])
  catch
    kind, err ->
      error_message = Kernel.CLI.format_error(kind, err, __STACKTRACE__)
      {:error, {kind, to_string(error_message)}}
  end

  def next(_), do: {:error, :ignored}

  defp next_reduce(ctx, module) do
    Enum.reduce_while(@stages, {:ok, ctx}, fn stage, {:ok, ctx} ->
      case Event.process(stage, module, ctx) do
        {:ok, ctx} -> {:cont, {:ok, ctx}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  @title_prefix "[ElixirBot Error] "

  @spec cleanup(reason, t()) :: :ok
  def cleanup({kind, message}, %{github: github, number: number})
      when kind in [:error, :exit, :throw] do
    number_str = if number, do: "##{number}", else: ""

    body = """
    #{number_str}
    ```elixir
    #{message}
    ```
    """

    issue_body = %{
      title: @title_prefix <> (message |> String.split("\n") |> List.first()),
      labels: ["bug"],
      body: body
    }

    {state, _result, _} = Github.invoke(github, &Tentacat.Issues.create/4, [issue_body])
    unless state in [200, 201], do: Logger.error("Create issue error: #{state}")
    :ok
  end

  def cleanup(_reason, _ctx), do: :ok

  defimpl Inspect do
    def inspect(%{state: state, result: result, stage: stage, id: id}, _opts) do
      id_str = if id, do: "<#{id}> ", else: ""
      "[#{stage}] #{id_str}{#{state}} #{inspect(result)}"
    end
  end
end
