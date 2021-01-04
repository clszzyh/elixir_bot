defmodule ElixirBotTest do
  use ExUnit.Case
  doctest ElixirBot

  test "basic md" do
    assert File.read!("test/fixtures/basic.md")
  end
end
