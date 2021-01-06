defmodule ElixirBot.Event do
  @moduledoc """
  Event

  https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows
  """

  alias Action.Github

  # @callback preproccess(Github.t()) :: ElixirBot.result()
  @callback before_process(Github.t()) :: ElixirBot.result()
  @callback process(Github.t()) :: ElixirBot.result()

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)

      alias Action.Github
      require Logger

      @impl true
      def before_process(g), do: {:ok, g}
      @impl true
      def process(g), do: {:ok, g}

      defoverridable unquote(__MODULE__)
    end
  end

  def before_proccess_all(g), do: {:ok, g}
  def proccess_all(g), do: {:ok, g}
end
