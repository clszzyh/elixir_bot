defmodule ElixirBot.Event do
  @moduledoc """
  Event

  https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows
  """

  alias Action.Github
  alias ElixirBot.Context
  require Logger

  @type result :: Context.result()
  @type stage :: Context.stage()

  @callback handle_event(stage, Context.t()) :: result()

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)

      alias Action.Github
      alias unquote(__MODULE__)
      require Logger
    end
  end

  @spec handle_invoke_result(Github.invoke_result(), Context.t()) :: result()
  def handle_invoke_result({state, result, _resp}, ctx) when state in [200, 201] do
    {:ok, %{ctx | state: state, result: result}}
  end

  def handle_invoke_result({state, %{"message" => message}, _resp}, _ctx) do
    {:error, "[#{state}] #{message}"}
  end

  @spec process(stage(), module(), Context.t()) :: result()
  def process(stage, module, %Context{} = ctx) do
    ctx = %{ctx | stage: stage}
    :ok = Logger.info(inspect(ctx))
    module.handle_event(stage, ctx)
  end
end
