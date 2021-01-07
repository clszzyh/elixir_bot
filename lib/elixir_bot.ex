defmodule ElixirBot do
  @external_resource readme = Path.join([__DIR__, "../README.md"])

  @moduledoc readme |> File.read!() |> String.split("<!-- MDOC -->") |> Enum.fetch!(2)

  @version Mix.Project.config()[:version]
  def version, do: @version

  alias Action.Github
  alias ElixirBot.Event
  require Logger

  @type result :: Action.t()

  @spec main :: :ok
  def main do
    {:ok, _} = Application.ensure_all_started(:elixir_bot)
    [_ | _] = Application.get_env(:tentacat, :extra_headers)
    {:ok, _} = HTTPoison.start()

    with {:ok, github} <- Github.init(),
         {:ok, github} <- handle(github) do
      Logger.debug(github)
    else
      {:error, reason} -> Logger.error(reason)
    end
  end

  @module_map %{
    "issue_comment" => Event.IssueComment,
    "issues" => Event.Issue
  }

  @spec handle(Github.t()) :: result()
  def handle(%{event_name: event_name} = github) when is_map_key(@module_map, event_name) do
    module = @module_map[event_name]

    with {:ok, github} <- Event.before_process(github),
         {:ok, github} <- module.before_process(github),
         {:ok, github} <- Event.process(github),
         {:ok, github} <- module.process(github),
         {:ok, github} <- Event.end_process(github) do
      {:ok, github}
    else
      err -> err
    end
  end

  def handle(_), do: {:error, :ignored}
end
