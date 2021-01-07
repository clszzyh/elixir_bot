defmodule ElixirBot.Event.IssueComment do
  @moduledoc """
  Issue Comment
  """

  use ElixirBot.Event

  @actions ["created", "edited"]

  @impl true
  def before_process(%Github{event: %{action: action, comment: %{body: body, id: id}}} = github)
      when action in @actions do
    Logger.debug(inspect({action, body}))
    {:ok, %{github | id: id}}
  end

  def before_process(_), do: {:error, :ignored}

  @impl true
  def process(%Github{id: id} = github) do
    result =
      Github.invoke(github, &Tentacat.Issues.Comments.Reactions.create/5, [
        id,
        %{content: "rocket"}
      ])

    {:ok, %{github | result: result}}
  end
end
