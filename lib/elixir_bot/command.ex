defmodule ElixirBot.Command do
  @moduledoc """
  Command
  """

  alias ElixirBot.Context
  alias ElixirBot.Event
  import NimbleParsec

  @version """
  * Elixir #{System.version()}
  * OTP #{:erlang.system_info(:system_version)}
  * ElixirBot #{Mix.Project.config()[:version]}
  """

  defparsec(
    :parse,
    choice([
      string("ping") |> replace(:ping),
      string("version") |> replace(:version)
    ])
  )

  @type major_command :: :ping | :version
  @type command :: {major_command, binary()}

  @spec handle(command(), Context.t()) :: {:ok, Event.run_result()}
  def handle({:ping, _}, _), do: {:ok, {:raw, "pong"}}
  def handle({:version, _}, _), do: {:ok, {:raw, @version}}
end
