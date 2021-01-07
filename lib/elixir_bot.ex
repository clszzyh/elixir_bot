defmodule ElixirBot do
  @external_resource readme = Path.join([__DIR__, "../README.md"])

  @moduledoc readme |> File.read!() |> String.split("<!-- MDOC -->") |> Enum.fetch!(2)

  @version Mix.Project.config()[:version]
  def version, do: @version

  alias Action.Github
  alias ElixirBot.Event
  require Logger

  @type result :: Action.t()

  @spec main :: :ok | :error
  def main do
    {:ok, _} = Application.ensure_all_started(:elixir_bot)
    [_ | _] = Application.get_env(:tentacat, :extra_headers)

    {:ok, github} = Github.init()

    try do
      case handle(github) do
        {:ok, _github} ->
          Logger.debug("ok")
          :ok

        {:error, %Github{stage: stage, result: result}} ->
          Logger.error("[#{stage}] #{result}")
          :error

        {:error, reason} ->
          Logger.error(reason)
          :error
      end
    catch
      kind, err ->
        error_message = Kernel.CLI.format_error(kind, err, __STACKTRACE__)

        body = """
        ```elixir
        #{error_message}
        ```
        """

        issue_body = %{
          title:
            "[ElixirBot Error] #{to_string(error_message) |> String.split("\n") |> List.first()}",
          labels: ["bug"],
          body: body
        }

        IO.puts(body)

        {_state, _result, _} = Github.invoke(github, &Tentacat.Issues.create/4, [issue_body])
        # IO.puts(inspect({state, result}))

        raise("ElixirBot Error")
    end
  end

  @module_map %{
    "issue_comment" => Event.IssueComment,
    "issues" => Event.Issue
  }

  @spec handle(Github.t()) :: result()
  def handle(%{event_name: event_name} = github) when is_map_key(@module_map, event_name) do
    module = @module_map[event_name]

    Enum.reduce_while(Event.stages(), {:ok, github}, fn stage, {:ok, github} ->
      case Event.process(stage, module, github) do
        {:ok, github} -> {:cont, {:ok, github}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  def handle(_), do: {:error, :ignored}
end
