defmodule ExEdnTest do
  use ExUnit.Case
  import ExEdn
  alias ExEdn.Character
  alias ExEdn.Symbol
  alias ExEdn.Exception, as: Ex

  test "Literals" do
    assert decode!("nil") == nil
    assert decode!("true") == true
    assert decode!("false") == false

    assert decode!("\"hello world!\"") == "hello world!"
    assert decode!("\"hello \\n world!\"") == "hello \n world!"

    assert decode!("\\n") == %Character{char: "n"}
    assert decode!("\\z") == %Character{char: "z"}

    assert decode!("a-symbol") == %Symbol{name: "a-symbol"}
    assert decode!(":the-keyword") == :'the-keyword'

    assert decode!("42") == 42
    assert decode!("42N") == 42

    assert decode!("42.0") == 42.0
    assert decode!("42M") == 42.0
    assert decode!("42.0e3") == 42000.0
    assert decode!("42e-3") == 0.042
    assert decode!("42E-1") == 4.2
    assert decode!("42.01E+1") == 420.1
  end

  test "List" do
    assert decode!("(1 :a 42.0)") == [1, :a, 42.0]
  end

  test "Vector" do
    array = Array.from_list([1, :a, 42.0])
    assert decode!("[1 :a 42.0]") == array
  end

  test "Map" do
    map = %{name: "John", age: 42}
    assert decode!("{:name \"John\" :age 42}") == map
  end

  test "Set" do
    set = Enum.into([:name, "John", :age, 42], HashSet.new)
    assert decode!("#\{:name \"John\" :age 42}") == set
  end

  test "Tag" do
    assert_raise Ex.NotImplementedError, fn ->
      decode!("#inst \"1985-04-12T23:20:50.52Z\"")
    end
  end

end
