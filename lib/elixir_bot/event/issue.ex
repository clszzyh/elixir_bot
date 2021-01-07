defmodule ElixirBot.Event.Issue do
  @moduledoc """
  Issue
  """

  use ElixirBot.Event

  @actions ["opened", "edited"]

  @impl true
  def handle_event(
        :parse,
        %Github{event: %{action: action, issue: %{body: body, number: number}}} = github
      )
      when action in @actions do
    Logger.debug(inspect({action, body, number}))
    {:ok, %{github | id: number}}
  end

  def handle_event(:parse, _), do: {:error, :ignored}

  def handle_event(:before, %Github{id: id} = github) do
    github
    |> Github.invoke(&Tentacat.Issues.Reactions.create/5, [id, %{content: "eyes"}])
    |> Event.handle_invoke_result(github)
  end
end
