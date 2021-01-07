defmodule ElixirBot.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    [_ | _] = Application.get_env(:tentacat, :extra_headers)

    children = [{ElixirBot.Server, nil}]

    Supervisor.start_link(children, strategy: :one_for_one, name: ElixirBot.Supervisor)
  end
end
