defmodule ElixirBot.Event.Issue do
  @moduledoc """
  Issue
  """

  use ElixirBot.Event

  @actions ["opened", "edited"]

  @impl true
  def name, do: "issues"

  @impl true
  def handle_event(
        :parse,
        %{github: %{event: %{action: action, issue: %{body: body, number: number}}}} = ctx
      )
      when action in @actions do
    Logger.debug(inspect({action, body, number}))

    case Markdown.init(body) do
      {:ok, markdown} -> {:ok, %{ctx | id: number, markdown: markdown, number: number}}
      {:error, reason} -> {:error, reason}
    end
  end

  def handle_event(:parse, _), do: {:error, :ignore_parse}
  def handle_event(:before, %{markdown: %{code: nil, ast: nil}}), do: {:error, :ignore_before}

  def handle_event(:before, %{number: id, github: github} = ctx) do
    github
    |> Github.invoke(&Tentacat.Issues.Reactions.create/5, [id, %{content: "eyes"}])
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
