defmodule ElixirBot.Event do
  @moduledoc """
  Event

  https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows
  """

  alias Action.Github
  alias ElixirBot.Code
  alias ElixirBot.Command
  alias ElixirBot.Context
  alias ElixirBot.Util
  require Logger

  @type result :: Context.result()
  @type stage :: Context.stage()
  @type run_result :: {:raw, binary()} | {{:code_block, :elixir | nil}, binary()}

  @callback name :: binary()
  @callback handle_event(stage, Context.t()) :: result()

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)

      alias Action.Github
      alias ElixirBot.Markdown
      alias unquote(__MODULE__)
      require Logger
    end
  end

  @spec handle_invoke_result(Github.invoke_result(), Context.t()) :: result()
  def handle_invoke_result({state, result, _resp}, ctx) when state in [200, 201] do
    {:ok, %{ctx | state: state, result: result}}
  end

  def handle_invoke_result({state, %{"message" => message}, _resp}, ctx) do
    {:error, "[#{state}] #{message}", ctx}
  end

  @spec process(stage(), module(), Context.t()) :: result()
  def process(stage, module, %Context{} = ctx) do
    ctx = %{ctx | stage: stage}
    :ok = Logger.info(inspect({stage, ctx}))
    module.handle_event(stage, ctx)
  catch
    kind, err ->
      error_message = Kernel.CLI.format_error(kind, err, __STACKTRACE__)
      {:error, {kind, to_string(error_message)}}
  end

  @spec handle_body(Context.t()) :: {:ok, binary(), Context.t()} | Context.error_result()
  def handle_body(%Context{markdown: %{body: body}} = ctx) do
    case handle_body_1(ctx) do
      {:error, reason} -> {:error, reason}
      {:ok, result} -> {:ok, concat_result(result, body), ctx}
      {:ok, result, ctx} -> {:ok, concat_result(result, body), ctx}
    end
  end

  defp handle_body_1(%{markdown: %{code: nil, command: nil}}), do: {:error, :process_ignored}

  defp handle_body_1(%{markdown: %{command: command}} = ctx) when command != nil,
    do: Command.handle(command, ctx)

  defp handle_body_1(%{markdown: %{code: code}} = ctx) when code != nil,
    do: Code.handle(code, ctx)

  defp concat_result(result, body) do
    result
    |> parse_result()
    |> Kernel.<>("\n\n----\n")
    |> Kernel.<>(Util.quote_text(body))
    |> Util.append_signature()
  end

  @spec parse_result(run_result) :: binary()
  defp parse_result({:raw, s}) when is_binary(s), do: s

  defp parse_result({{:code_block, type}, s}) when is_binary(s),
    do: Util.elixir_code_block(s, type)
end
