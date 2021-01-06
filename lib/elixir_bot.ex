defmodule ElixirBot do
  @external_resource readme = Path.join([__DIR__, "../README.md"])

  @moduledoc readme |> File.read!() |> String.split("<!-- MDOC -->") |> Enum.fetch!(2)

  @version Mix.Project.config()[:version]
  def version, do: @version

  alias Action.Github
  alias ElixirBot.Events
  require Logger

  @type result :: Action.t()

  @spec main :: :ok
  def main do
    result =
      with {:ok, github} <- Github.init(),
           {:ok, github} <- handle(github) do
        github
      else
        err -> err
      end

    Logger.debug(result)
  end

  @module_map %{
    "issue_comment" => Events.IssueComment,
    "issues" => Events.Issue
  }

  @spec handle(Github.t()) :: result()
  def handle(%{event_name: event_name} = github) when is_map_key(@module_map, event_name) do
    @module_map[event_name].handle(github)
  end

  def handle(_), do: {:error, :ignored}

  # @spec result(result(), Github.t()) :: :ok
  # defp result(:ok, %{event_name: event_name}) do
  #   Logger.debug("[ok] #{event_name}")
  #   :ok
  # end
  # defp result(:ignore, %{event_name: event_name}) do
  #   Logger.error("[ignore] #{event_name}")
  #   :ok
  # end
end
