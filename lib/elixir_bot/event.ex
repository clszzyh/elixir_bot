defmodule ElixirBot.Event do
  @moduledoc """
  Event

  https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows
  """

  alias Action.Github
  require Logger

  @type result :: ElixirBot.result()

  # @callback preproccess(Github.t()) :: ElixirBot.result()
  @callback before_process(Github.t()) :: result()
  @callback process(Github.t()) :: result()

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)

      alias Action.Github
      alias unquote(__MODULE__)
      require Logger

      @impl true
      def before_process(g), do: {:ok, g}
      @impl true
      def process(g), do: {:ok, g}

      defoverridable unquote(__MODULE__)
    end
  end

  @spec handle_invoke_result(Github.invoke_result(), Github.t()) :: result()
  def handle_invoke_result({state, result, _resp}, github) when state in [200, 201] do
    {:ok, %{github | state: state, result: result}}
  end

  def handle_invoke_result({state, %{"message" => message}, _resp}, _) do
    {:error, "[#{state}] #{message}"}
  end

  @spec before_process(Github.t()) :: result()
  def before_process(%Github{} = g) do
    {:ok, info(%{g | stage: :before_process})}
  end

  @spec process(Github.t()) :: result()
  def process(%Github{} = g) do
    {:ok, info(%{g | stage: :process})}
  end

  @spec end_process(Github.t()) :: result()
  def end_process(%Github{} = g) do
    {:ok, info(%{g | stage: :end_process})}
  end

  defp info(g) do
    Logger.info(inspect(g))
    g
  end
end
