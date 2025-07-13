defmodule StructoTest do
  @moduledoc false
  use ExUnit.Case

  import Structo

  describe "regular maps" do
    test "creates maps with atom keys from variables" do
      a = 1
      b = 2
      assert ~m{a, b} == %{a: 1, b: 2}
    end

    test "creates maps with explicit key-value pairs" do
      assert ~m{a: 1, b: 2} == %{a: 1, b: 2}
    end

    test "mixes variables and explicit values" do
      a = 1
      assert ~m{a, b: 2} == %{a: 1, b: 2}
    end

    test "handles complex expressions as values" do
      list = [1, 2, 3]
      assert ~m{sum: Enum.sum(list)} == %{sum: 6}
    end

    test "handles nested map construction" do
      inner = %{x: 1}
      assert ~m{outer: inner.x + 1} == %{outer: 2}
    end

    test "ignores duplicate keys (keeps first occurrence)" do
      a = 1
      assert ~m{a, a: 2} == %{a: 1}
    end
  end

  describe "string maps" do
    test "creates maps with string keys from variables" do
      a = 1
      b = 2
      assert ~m{a, b}s == %{"a" => 1, "b" => 2}
    end

    test "creates maps with string keys from explicit values" do
      assert ~m{a: 1, b: 2}s == %{"a" => 1, "b" => 2}
    end

    test "mixes variables and explicit values with string keys" do
      a = 1
      assert ~m{a, b: 2}s == %{"a" => 1, "b" => 2}
    end
  end

  describe "structs" do
    defmodule TestStruct do
      defstruct [:a, :b, :c]
    end

    defmodule AnotherTestStruct do
      import Structo
      defstruct [:x, :y]

      def create_with_module do
        x = 10
        ~m{:__MODULE__, x, y: 20}
      end
    end

    test "creates structs with module name" do
      a = 1
      assert ~m{:TestStruct, a, b: 2} == %TestStruct{a: 1, b: 2}
    end

    test "creates structs with __MODULE__" do
      assert AnotherTestStruct.create_with_module() == %AnotherTestStruct{x: 10, y: 20}
    end

    test "resolves aliased module names" do
      alias StructoTest.TestStruct, as: TS
      a = 1
      assert ~m{:TS, a, b: 2} == %TestStruct{a: 1, b: 2}
    end

    test "full module names work even with aliases" do
      alias StructoTest.TestStruct, as: TS
      a = 1
      assert ~m{:StructoTest.TestStruct, a, b: 2} == %TS{a: 1, b: 2}
    end

    test "handles structs in matches" do
      assert ~m{:TestStruct} = %TestStruct{a: 1, b: 2}
    end
  end

  describe "pattern matching" do
    test "matches maps with variables" do
      map = %{a: 1, b: 2, c: 3}
      assert ~m{a, b} = map
      assert a == 1
      assert b == 2
    end

    test "matches maps with explicit values" do
      map = %{a: 1, b: 2}
      assert ~m{a: 1, b} = map
      assert b == 2
    end

    test "matches nested structures" do
      map = %{data: %{x: 10, y: 20}}
      assert ~m{data: inner} = map
      assert inner == %{x: 10, y: 20}
    end

    test "matches with string keys" do
      map = %{"a" => 1, "b" => 2}
      assert ~m{a, b}s = map
      assert a == 1
      assert b == 2
    end
  end

  describe "integration with real modules" do
    defmodule User do
      defstruct [:name, :age, :email]
    end

    test "works with real struct definitions" do
      name = "John"
      age = 30
      result = ~m{:User, name, age, email: "john@example.com"}

      assert %User{name: "John", age: 30, email: "john@example.com"} = result
    end

    test "pattern matches real structs" do
      user = %User{name: "Jane", age: 25, email: "jane@example.com"}

      assert ~m{:User, name, age} = user
      assert name == "Jane"
      assert age == 25
    end
  end

  describe "edge cases" do
    defmodule EmptyStruct do
      defstruct []
    end

    test "handles empty maps" do
      assert ~m{} == %{}
    end

    test "handles empty structs" do
      assert ~m{:EmptyStruct} == %EmptyStruct{}
    end

    test "handles atoms as values" do
      assert ~m{status: :ok, type: :user} == %{status: :ok, type: :user}
    end

    test "handles tuples as values" do
      coord_tuple = {1, 2}
      assert ~m{coord: coord_tuple} == %{coord: {1, 2}}
    end

    test "handles lists as values" do
      items = [1, 2, 3]
      assert ~m{items} == %{items: [1, 2, 3]}
    end

    test "handles maps as values" do
      nested = %{x: 1}
      assert ~m{nested} == %{nested: %{x: 1}}
    end
  end
end
