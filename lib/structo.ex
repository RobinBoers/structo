defmodule Structo do
  @moduledoc """
  JavaScript-style object constructors.

  This library allows you to construct maps and structs like this:

      ~m{a, b, c: d}

  Instead of:

      %{a: a, b: b, c: d}

  And it works in matches too:

      iex> ~m{a, b: 2} = %{a: 1, b: 2}
      iex> a
      1

  """

  @doc false
  def parse(expression) do
    expression
    |> String.split(~r/\s*,\s*/, trim: true)
    |> Enum.map(&parse_segments/1)
    |> Enum.uniq_by(fn {key, _} -> key end)
  end

  @doc false
  def parse_segments(segment) do
    case String.split(segment, ":", parts: 2) do
      [key, value] -> {trimmed_atom(key), trimmed_quote(value)}
      [key] -> {trimmed_atom(key), Macro.var(trimmed_atom(key), nil)}
    end
  end

  defp trimmed_atom(s), do: s |> String.trim() |> String.to_atom()
  defp trimmed_quote(v), do: v |> String.trim() |> Code.string_to_quoted!()

  @doc """
  This sigil acts as a shorthand for constructing maps with
  JavaScript-like syntax.

  ## Examples

      iex> import Structo
      iex> a = 1; b = 2; d = 3
      iex> ~m{a, b, c: d}
      %{a: 1, b: 2, c: 3}

  """
  defmacro sigil_m({:<<>>, _meta, [expr]}, []) do
    quote do
      %{unquote_splicing(parse(expr))}
    end
  end

  @doc """
  While it is a giant hack, this library can semi-work for
  structs as well. Just `use Structo` in your module:

      defmodule MyStruct do
        use Structo
        defstruct [:a, :b]
      end

  And then construct your structs like this:

      iex> import MyStruct
      iex> a = "wibble"
      iex> ~MYSTRUCT{a, b: "wobble"}
      %MyStruct{a: "wibble", b: "wobble"}

  Unfortunately, the module name has to be upcased, due to Elixir's 
  restrictions on sigil names.
  """
  defmacro __using__(_opts) do
    mod = inspect(__CALLER__.module)
    sigil = :"sigil_#{String.upcase(mod)}"

    quote do
      defmacro unquote(sigil)({:<<>>, _, [expr]}, []) do
        quote do
          %unquote(__MODULE__){unquote_splicing(Structo.parse(expr))}
        end
      end
    end
  end
end
