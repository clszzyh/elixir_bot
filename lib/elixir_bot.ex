defmodule ElixirBot do
  @external_resource readme = Path.join([__DIR__, "../README.md"])

  @moduledoc readme |> File.read!() |> String.split("<!-- MDOC -->") |> Enum.fetch!(2)

  @version Mix.Project.config()[:version]
  def version, do: @version

  def main(args) do
    IO.puts(inspect({:invoke, args}))
    IO.puts(inspect({:argv, System.argv()}))
    IO.puts(inspect({:invoke, System.argv(args)}))

    options = [switches: [file: :string], aliases: [f: :file]]
    result = OptionParser.parse!(args, options)
    IO.puts(inspect(result))
  end
end
