defmodule ElixirBot.Event do
  @moduledoc """
  Event

  https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows
  """

  alias Action.Github
  require Logger

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

  def before_process(%Github{event_name: event_name, result: result} = g) do
    Logger.info("[before process] #{event_name} #{inspect(result)}")
    {:ok, g}
  end

  def process(%Github{event_name: event_name, result: result} = g) do
    Logger.info("[process] #{event_name} #{inspect(result)}")
    Logger.error("#{inspect(Application.get_env(:tentacat, :extra_headers, []))}")
    {:ok, g}
  end

  def end_process(%Github{event_name: event_name, result: result} = g) do
    Logger.info("[end process] #{event_name} #{inspect(result)}")
    {:ok, g}
  end
end
