defmodule ElixirBot do
  @external_resource readme = Path.join([__DIR__, "../README.md"])

  @moduledoc readme |> File.read!() |> String.split("<!-- MDOC -->") |> Enum.fetch!(2)

  @version Mix.Project.config()[:version]
  def version, do: @version

  @type t :: %__MODULE__{
          token: binary(),
          owner: binary(),
          repo: binary()
        }
  @enforce_keys [:token, :owner, :repo]
  defstruct [:token, :owner, :repo]

  def main(args) do
    options = [strict: [token: :string, repo: :string]]

    {[token: token, repo: repo_name], _, _} = OptionParser.parse(args, options)
    [owner, repo | []] = String.split(repo_name, "/")

    opt = %__MODULE__{token: token, owner: owner, repo: repo}

    IO.puts(inspect({args, opt}))
  end
end
