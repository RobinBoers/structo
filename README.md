# Structo

<!-- DOCS HERE -->

JavaScript-style object constructors.

This library allows you to construct maps and structs like this:

```elixir
~m{a, b, c: d}
```

Instead of:

```elixir
%{a: a, b: b, c: d}
```

And it works in matches too:

```elixir
iex> ~m{a, b: 2} = %{a: 1, b: 2}
iex> a
1
```
