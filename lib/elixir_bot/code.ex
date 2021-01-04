defmodule ElixirBot.Code do
  @moduledoc """
  Code
  """

  alias ElixirBot.Context
  alias ElixirBot.Event

  @spec handle(binary(), Context.t()) :: {:ok, Event.run_result(), Context.t()}
  def handle(code, ctx) do
    code
    |> Sand.run()
    |> case do
      {:ok, result, box} -> {:ok, format_result(result), %{ctx | state: :ok, result: box}}
      {:error, reason} -> {:ok, format_result(reason), %{ctx | state: :error}}
    end
  end

  defp format_result(result) do
    {{:code_block, :elixir}, inspect(result, pretty: true)}
  end
end
