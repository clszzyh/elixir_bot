defmodule ElixirBot.Markdown do
  @moduledoc """
  Markdown
  """

  alias ElixirBot.Command

  @type command :: Command.command() | nil
  @type code :: binary() | nil
  @type ast :: EarmarkParser.ast()

  @type t :: %__MODULE__{
          body: binary(),
          ast: ast,
          code: code,
          command: command()
        }

  @enforce_keys [:body, :ast, :command, :code]
  defstruct @enforce_keys

  @prefix "@ex-bot "
  @code_prefix_line "## @ex-bot\n"

  def prefix, do: @prefix

  @spec init(binary()) :: {:ok, t()} | {:error, term()}
  def init(body) do
    with {:ok, ast, _} <- EarmarkParser.as_ast(body),
         {:ok, code} <- build_code(ast),
         {:ok, command} <- build_command(body) do
      {:ok, %__MODULE__{body: body, ast: ast, code: code, command: command}}
    else
      {:error, reason} -> {:error, reason}
      {:error, _ast, reason} -> {:error, reason}
    end
  end

  @spec build_code(ast) :: {:ok, code}
  defp build_code(ast) do
    {:ok, Enum.find_value(ast, &fetch_code/1)}
  end

  defp fetch_code(
         {"pre", _, [{"code", [{"class", "elixir"} | _], [@code_prefix_line <> code], _}], _}
       ) do
    code
  end

  defp fetch_code(_), do: nil

  @spec build_command(binary) :: {:ok, command}
  defp build_command(@prefix <> rest) do
    case Command.parse(rest) do
      {:ok, [cmd], rest, _, _, _} -> {:ok, {cmd, rest}}
      {:error, message, _, _, _, _} -> {:error, message}
    end
  end

  defp build_command(_), do: {:ok, nil}
end
