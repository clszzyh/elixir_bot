defmodule ElixirBot.Event.IssueComment do
  @moduledoc """
  Issue Comment
  """

  use ElixirBot.Event

  @actions ["created", "edited"]

  @impl true
  def handle_event(
        :parse,
        %{github: %{event: %{action: action, comment: %{body: body, number: number, id: id}}}} =
          ctx
      )
      when action in @actions do
    Logger.debug(inspect({action, body}))
    {:ok, %{ctx | id: id, body: body, number: number}}
  end

  def handle_event(:parse, _), do: {:error, :ignored}

  def handle_event(:before, %{github: github, id: id} = ctx) do
    github
    |> Github.invoke(&Tentacat.Issues.Comments.Reactions.create/5, [id, %{content: "rocket"}])
    |> Event.handle_invoke_result(ctx)
  end
end
