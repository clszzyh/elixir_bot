defmodule ElixirBot.Tracker do
  @moduledoc """
  Tracker
  """

  @name Trackable

  defprotocol Module.concat(__MODULE__, @name) do
    def module(s)
  end

  def modules(module) do
    {:consolidated, modules} = Module.concat(__MODULE__, @name).__protocol__(:impls)

    for m <- modules, m.__used_module__() == module, do: m
  end

  defmacro __using__(opt) do
    quote do
      defimpl unquote(__MODULE__).unquote(@name) do
        def module(_), do: :ok
      end

      def __used_module__, do: unquote(opt)
    end
  end
end
