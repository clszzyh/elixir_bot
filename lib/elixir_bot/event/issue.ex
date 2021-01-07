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

  @impl true
  def process(%Github{id: id} = github) do
    github
    |> Github.invoke(&Tentacat.Issues.Reactions.create/5, [id, %{content: "eyes"}])
    |> Event.handle_invoke_result(github)
  end
end
