defmodule ElixirBot.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [{ElixirBot.Server, nil}]
    # children = [{ElixirBot.Server, File.read!("priv/local.json")}]

    Supervisor.start_link(children, strategy: :one_for_one, name: ElixirBot.Supervisor)
  end
end
