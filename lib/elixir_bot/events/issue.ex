defmodule ElixirBot.Events.Issue do
  @moduledoc """
  Issue
  """

  use ElixirBot.Event

  @actions ["opened", "edited"]

  @impl true
  def handle(%Github{event: %{action: action, issue: %{body: body}}} = github)
      when action in @actions do
    Logger.debug(inspect({action, body}))
    {:ok, github}
  end

  def handle(_), do: {:error, :ignored}
end
