defmodule ElixirBot.Events.Issue do
  @moduledoc """
  Issue
  """

  use ElixirBot.Event

  @actions ["opened", "edited"]

  @impl true
  def handle(%Github{event: %{action: action, issue: %{body: body}}}) when action in @actions do
    Logger.debug(inspect({action, body}))
  end

  def handle(_), do: :ignored
end
