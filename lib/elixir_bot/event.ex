defmodule ElixirBot.Event do
  @moduledoc """
  Event

  https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows
  """

  alias Action.Github
  require Logger

  @type result :: ElixirBot.result()
  @type stage :: :parse | :before | :process

  @stages [:parse, :before, :process]

  def stages, do: @stages

  @callback handle_event(stage, Github.t()) :: result()

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)

      alias Action.Github
      alias unquote(__MODULE__)
      require Logger
    end
  end

  @spec handle_invoke_result(Github.invoke_result(), Github.t()) :: result()
  def handle_invoke_result({state, result, _resp}, github) when state in [200, 201] do
    {:ok, %{github | state: state, result: result}}
  end

  def handle_invoke_result({state, %{"message" => message}, _resp}, github) do
    {:error, %{github | state: state, result: "[#{state}] #{message}"}}
  end

  @spec process(stage(), module(), Github.t()) :: result()
  def process(stage, module, %Github{} = g) do
    g = %{g | stage: stage}
    :ok = Logger.info(inspect(g))
    module.handle_event(stage, g)
  end
end
