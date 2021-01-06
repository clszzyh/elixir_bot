defmodule ElixirBot do
  @external_resource readme = Path.join([__DIR__, "../README.md"])

  @moduledoc readme |> File.read!() |> String.split("<!-- MDOC -->") |> Enum.fetch!(2)

  @version Mix.Project.config()[:version]
  def version, do: @version

  require Logger

  # @typep result :: :ok | :ignore

  @spec main :: :ok
  def main do
    Logger.configure(truncate: :infinity)
    Logger.info(inspect(System.get_env(), pretty: true))

    github = Action.Github.init()
    Logger.info(inspect(github, pretty: true))
    Logger.configure(truncate: 8192)
    :ok
    # opt |> handle() |> result(opt)
  end

  # @spec handle(t()) :: result()
  # def handle(%__MODULE__{
  #       event_name: "issue_comment",
  #       event: %{action: action, comment: %{body: body}}
  #     })
  #     when action in ["created"] do
  #   Logger.warn(action: action, body: body)
  #   :ok
  # end

  # def handle(%__MODULE__{event_name: "issues", event: %{action: action, issue: %{body: body}}})
  #     when action in ["opened", "edited"] do
  #   Logger.warn(action: action, body: body)
  #   :ok
  # end

  # def handle(_), do: :ignore
  # @spec result(result(), t()) :: :ok
  # defp result(:ok, %__MODULE__{event_name: event_name}) do
  #   Logger.info("[ok] #{event_name}")
  #   :ok
  # end
  # defp result(:ignore, %__MODULE__{event_name: event_name}) do
  #   Logger.info("[ignore] #{event_name}")
  #   :ok
  # end
end
