defmodule ElixirBot.Events.IssueComment do
  @moduledoc """
  Issue Comment
  """

  use ElixirBot.Event

  @actions ["created"]

  @impl true
  def handle(%Github{event: %{action: action, comment: %{body: body}}} = github)
      when action in @actions do
    Logger.debug(inspect({action, body}))
    {:ok, github}
  end

  def handle(_), do: :ignored
end
