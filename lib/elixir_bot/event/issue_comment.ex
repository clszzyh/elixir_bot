defmodule ElixirBot.Event.IssueComment do
  @moduledoc """
  Issue Comment
  """

  use ElixirBot.Event

  @actions ["created", "edited"]

  @impl true
  def name, do: "issue_comment"

  @impl true
  def handle_event(
        :parse,
        %{
          github: %{
            event: %{action: action, issue: %{number: number}, comment: %{body: body, id: id}}
          }
        } = ctx
      )
      when action in @actions do
    Logger.debug(inspect({action, body}))

    case Markdown.init(body) do
      {:ok, markdown} -> {:ok, %{ctx | id: id, markdown: markdown, number: number}}
      {:error, reason} -> {:error, reason}
    end
  end

  def handle_event(:parse, _), do: {:error, :ignore_parse}
  def handle_event(:before, %{markdown: %{code: nil, command: nil}}), do: {:error, :ignore_before}

  def handle_event(:before, %{github: github, id: id} = ctx) do
    github
    |> Github.invoke(&Tentacat.Issues.Comments.Reactions.create/5, [id, %{content: "rocket"}])
    |> Event.handle_invoke_result(ctx)
  end

  def handle_event(:process, %{number: id, github: github} = ctx) do
    case Event.handle_body(ctx) do
      {:error, reason} ->
        {:error, reason}

      {:ok, body, ctx} ->
        github
        |> Github.invoke(&Tentacat.Issues.Comments.create/5, [id, %{body: body}])
        |> Event.handle_invoke_result(ctx)
    end
  end
end
