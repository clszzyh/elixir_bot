defmodule ElixirBot.Event.IssueComment do
  @moduledoc """
  Issue Comment
  """

  use ElixirBot.Event

  @actions ["created"]

  @impl true
  def before_process(%Github{event: %{action: action, comment: %{body: body}}} = github)
      when action in @actions do
    Logger.debug(inspect({action, body}))
    {:ok, github}
  end

  def before_process(_), do: {:error, :ignored}
end
