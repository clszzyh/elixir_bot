defmodule ElixirBot.Event.IssueComment do
  @moduledoc """
  Issue Comment
  """

  use ElixirBot.Event

  @actions ["created", "edited"]

  @impl true
  def handle_event(
        :parse,
        %Github{event: %{action: action, comment: %{body: body, id: id}}} = github
      )
      when action in @actions do
    Logger.debug(inspect({action, body}))
    {:ok, %{github | id: id}}
  end

  def handle_event(:parse, _), do: {:error, :ignored}

  def handle_event(:before, %Github{id: id} = github) do
    github
    |> Github.invoke(&Tentacat.Issues.Comments.Reactions.create/5, [id, %{content: "rocket"}])
    |> Event.handle_invoke_result(github)
  end
end
