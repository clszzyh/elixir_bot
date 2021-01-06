defmodule ElixirBot do
  @external_resource readme = Path.join([__DIR__, "../README.md"])

  @moduledoc readme |> File.read!() |> String.split("<!-- MDOC -->") |> Enum.fetch!(2)

  @version Mix.Project.config()[:version]
  def version, do: @version

  alias Action.Github
  alias ElixirBot.Events
  require Logger

  @type result :: :ok | :ignore

  @spec main :: :ok
  def main do
    %Github{} = github = Github.init()
    github |> handle() |> result(github)
  end

  @module_map %{
    "issue_comment" => Events.IssueComment,
    "issues" => Events.Issue
  }

  @spec handle(Github.t()) :: result()
  def handle(%{event_name: event_name} = github) when is_map_key(@module_map, event_name) do
    @module_map[event_name].handle(github)
  end

  def handle(_), do: :ignore
  @spec result(result(), Github.t()) :: :ok
  defp result(:ok, %{event_name: event_name}) do
    Logger.debug("[ok] #{event_name}")
    :ok
  end

  defp result(:ignore, %{event_name: event_name}) do
    Logger.error("[ignore] #{event_name}")
    :ok
  end
end
