defmodule ElixirBot.Event.Issue do
  @moduledoc """
  Issue
  """

  use ElixirBot.Event

  @actions ["opened", "edited"]

  @impl true
  def before_process(
        %Github{event: %{action: action, issue: %{body: body, number: number}}} = github
      )
      when action in @actions do
    Logger.debug(inspect({action, body, number}))
    {:ok, %{github | id: number}}
  end

  def before_process(_), do: {:error, :ignored}
end
