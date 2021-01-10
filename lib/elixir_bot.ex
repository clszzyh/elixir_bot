defmodule ElixirBot do
  @external_resource readme = Path.join([__DIR__, "../README.md"])

  @moduledoc readme
             |> File.read!()
             |> String.split("<!-- MDOC -->")
             |> Enum.slice(1..-2)
             |> Enum.join("\n")

  @version Mix.Project.config()[:version]
  def version, do: @version

  alias ElixirBot.Server
  require Logger

  @spec main :: :ok
  def main do
    {:ok, _} = Application.ensure_all_started(:elixir_bot)
    :ok = Server.next()
  end
end
