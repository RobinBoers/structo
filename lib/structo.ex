defmodule Structo do
  @moduledoc """
  JavaScript-style object constructors.

  This library allows you to construct maps and structs like this:

      ~m{a, b}

  Instead of:

      %{a: a, b: b}

  And it works in matches too:

      iex> ~m{a, b} = %{a: 1, b: 2}
      iex> a
      1
      iex> b
      2

  ## Structs

  The library works for structs too. Just `use Structo` in your module:

      defmodule MyStruct do
        use Structo
        defstruct [:a, :b]
      end

  And then construct your structs like this:

      import MyStruct
      ~MYSTRUCT{a, b}

  (Unfortunately, the struct name has to be upcased.)
  """

  defmacro sigil_m({:<<>>, _meta, [expr]}, []) do
    fields =
      expr
      |> String.split(~r/\s*,\s*/, trim: true)
      |> Enum.map(&String.to_atom/1)
      |> Enum.uniq()
      |> Enum.map(&{&1, Macro.var(&1, nil)})

    quote do
      %{unquote_splicing(fields)}
    end
  end

  defmacro __using__(_opts) do
    module = __CALLER__.module

    quote do
      defmacro unquote(:"sigil_#{String.upcase(inspect(module))}")({:<<>>, _, [expr]}, []) do
        fields =
          expr
          |> String.split(~r/\s*,\s*/, trim: true)
          |> Enum.map(&String.to_atom/1)
          |> Enum.uniq()
          |> Enum.map(&{&1, Macro.var(&1, nil)})

        quote do
          %unquote(__MODULE__){unquote_splicing(fields)}
        end
      end
    end
  end
end
