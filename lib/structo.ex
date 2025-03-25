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
  def parse!(expression) do
    expression
    |> String.split(~r/\s*,\s*/, trim: true)
    |> parse_segments()
  end

  @doc false
  def parse_segments([":" <> module | segments]) do
    {module, parse_fields(segments)}
  end

  @doc false
  def parse_segments(s), do: parse_fields(s)

  @doc false
  def parse_fields(segments) when is_list(segments) do
    segments
    |> Enum.map(&parse_segment/1)
    |> Enum.uniq_by(fn {key, _} -> key end)
  end

  @doc false
  def parse_segment(segment) when is_binary(segment) do
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

  ## String keys

  The optional `s` modifier can be used to construct a map using
  string keys rather than atom keys:

      iex> import Structo
      iex> a = 1; b = 2; d = 3
      iex> ~m{a, b, c: d}s
      %{"a" => 1, "b" => 2, "c" => 3}

  ## Structs

  This library can construct standard Elixir structs too:

      iex> import Structo
      iex> alias Hello.MyStruct
      iex> a = 1
      iex> ~m{:MyStruct, a, b: 2}
      %Hello.MyStruct{a: 1, b: 2}

  This syntax is preferred over the deprecated `use Structo` behaviour,
  which will be removed in the next release.
  """
  defmacro sigil_m({:<<>>, _meta, [expr]}, [?s]) do
    fields = for {k, v} <- parse!(expr), do: {to_string(k), v}

    quote do
      %{unquote_splicing(fields)}
    end
  end

  defmacro sigil_m({:<<>>, _meta, [expr]}, []) do
    case parse!(expr) do
      {"__MODULE__", fields} when is_list(fields) ->
        quote do
          %__MODULE__{unquote_splicing(fields)}
        end

      {mod, fields} when is_list(fields) ->
        mod = resolve_aliases(mod, __CALLER__.aliases)

        quote do
          %unquote(mod){unquote_splicing(fields)}
        end

      fields when is_list(fields) ->
        quote do
          %{unquote_splicing(fields)}
        end
    end
  end

  defp resolve_aliases(mod, aliases) do
    m = Module.concat([mod])

    case Enum.find(aliases, fn {a, _} -> a == m end) do
      {_, module} -> module
      nil -> Module.concat([m])
    end
  end

  defmacro __using__(_opts) do
    mod = inspect(__CALLER__.module)
    sigil = :"sigil_#{String.upcase(mod)}"

    quote do
      @deprecated "Use `sigil_m/2` instead"
      defmacro unquote(sigil)({:<<>>, _, [expr]}, []) do
        quote do
          %unquote(__MODULE__){unquote_splicing(Structo.parse(expr))}
        end
      end
    end
  end
end
