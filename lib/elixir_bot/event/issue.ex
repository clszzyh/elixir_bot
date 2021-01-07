defmodule ElixirBot.Event.Issue do
  @moduledoc """
  Issue
  """

  use ElixirBot.Event

  @actions ["opened", "edited"]

  @impl true
  def handle_event(
        :parse,
        %{github: %{event: %{action: action, issue: %{body: body, number: number}}}} = ctx
      )
      when action in @actions do
    Logger.debug(inspect({action, body, number}))
    {:ok, %{ctx | id: number, body: body, number: number}}
  end

  def handle_event(:parse, _), do: {:error, :ignored}

  def handle_event(:before, %{number: id, github: github} = ctx) do
    github
    |> Github.invoke(&Tentacat.Issues.Reactions.create/5, [id, %{content: "eyes"}])
    |> Event.handle_invoke_result(ctx)
  end
end
