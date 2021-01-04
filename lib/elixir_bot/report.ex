defmodule ElixirBot.Report do
  @moduledoc """
  Report
  """

  alias Action.Github
  alias ElixirBot.Util
  require Logger

  @title_prefix "[ElixirBot Error] "

  @spec issue(Github.t(), binary(), binary(), [binary()]) :: :ok
  def issue(github, title, body, tags) do
    issue_body = %{
      title: @title_prefix <> title,
      labels: tags,
      body: Util.append_signature(body)
    }

    if System.get_env("INPUT_REPORT_ISSUE", "true") == "true" do
      {state, result, _} = Github.invoke(github, &Tentacat.Issues.create/4, [issue_body])

      unless state in [200, 201],
        do: Logger.error("Create issue error: #{state}, #{inspect(result)}")
    end

    :ok
  end
end
