defmodule ExEdnTest do
  use ExUnit.Case
  import ExEdn
  alias ExEdn.Character
  alias ExEdn.Symbol
  alias ExEdn.UUID
  alias ExEdn.Tag
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
    date = Timex.DateFormat.parse("1985-04-12T23:20:50.52Z", "{RFC3339z}")
    assert decode!("#inst \"1985-04-12T23:20:50.52Z\"") == date
    assert decode!("#uuid \"f81d4fae-7dec-11d0-a765-00a0c91e6bf6\"") == %UUID{value: "f81d4fae-7dec-11d0-a765-00a0c91e6bf6"}

    assert decode!("#custom/tag (1 2 3)") == %Tag{name: "custom/tag", value: [1, 2, 3]}
    handlers = %{"custom/tag" => &custom_tag_handler/1}
    assert decode!("#custom/tag (1 2 3)", handlers: handlers) == [:a, :b, :c]
  end

  def custom_tag_handler(value) when is_list(value) do
    mapping = %{1 => :a, 2 => :b, 3 => :c}
    Enum.map(value, fn x -> mapping[x] end)
  end
end
