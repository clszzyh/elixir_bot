defmodule ElixirBot.Util do
  @moduledoc """
  Util
  """

  @external_resource readme = Path.join([__DIR__, "../../README.md"])
  @commands readme |> File.read!() |> String.split("<!-- MDOC -->") |> Enum.fetch!(3)
  @signature """

  <details><summary>Support Commands</summary>
  <hr>
  #{@commands}
  </details>
  """

  def elixir_code_block(binary, type) do
    """
    ```#{type}
    #{binary}
    ```
    """
  end

  @spec quote_text(binary()) :: binary()
  def quote_text(b) when is_binary(b) do
    b |> String.split("\n") |> Enum.map_join("\n", fn x -> "> " <> x end)
  end

  @spec append_signature(binary()) :: binary()
  def append_signature(body) do
    body <> @signature
  end
end
