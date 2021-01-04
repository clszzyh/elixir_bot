defmodule ElixirBot do
  @external_resource readme = Path.join([__DIR__, "../README.md"])

  @moduledoc readme |> File.read!() |> String.split("<!-- MDOC -->") |> Enum.fetch!(2)

  @version Mix.Project.config()[:version]
  def version, do: @version

  @doc """
  Hello world.

  ## Examples

      iex> ElixirBot.hello()
      :world

  """
  def hello do
    :world
  end
end
