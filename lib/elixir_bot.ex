defmodule ElixirBot do
  @external_resource readme = Path.join([__DIR__, "../README.md"])

  @moduledoc readme |> File.read!() |> String.split("<!-- MDOC -->") |> Enum.fetch!(2)

  @version Mix.Project.config()[:version]
  def version, do: @version

  require Logger
  alias Action.Api
  alias Action.Github

  @typep result :: :ok | :ignore

  @spec main :: :ok
  def main do
    %Github{} = github = Github.init()
    github |> handle() |> result(github)
    :ok
    # opt |> handle() |> result(opt)
  end

  @spec handle(Github.t()) :: result()
  def handle(%{event_name: "issue_comment", event: %{action: action, comment: %{body: body}}})
      when action in ["created"] do
    Api.debug(inspect({action, body}))
    :ok
  end

  def handle(%{event_name: "issues", event: %{action: action, issue: %{body: body}}})
      when action in ["opened", "edited"] do
    Api.debug(inspect({action, body}))
    :ok
  end

  def handle(_), do: :ignore
  @spec result(result(), Github.t()) :: :ok
  defp result(:ok, %{event_name: event_name}) do
    Api.debug("[ok] #{event_name}")
    :ok
  end

  defp result(:ignore, %{event_name: event_name}) do
    Api.error("[ignore] #{event_name}")
    :ok
  end
end
