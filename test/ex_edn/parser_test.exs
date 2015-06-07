defmodule ExEdn.ParserTest do
  use ExUnit.Case
  import ExEdn.Parser
  alias ExEdn.Parser
  alias ExEdn.Exception, as: Ex

  test "Whitespace" do
    assert parse(",,,  ") == node(:root, nil, [])
    assert parse(" \n \t, \r") == node(:root, nil, [])
  end

  test "Literals" do
    root = node(:root, nil, [node(:nil, "nil"),
                             node(:true, "true"),
                             node(:false, "false")])
    assert parse("nil true false") == root

    root = node(:root, nil, [node(:integer, "1")])
    assert parse("1") == root
    root = node(:root, nil, [node(:integer, "29382329N")])
    assert parse("29382329N") == root

    root = node(:root, nil, [node(:float, "29382329M")])
    assert parse("29382329M") == root
    root = node(:root, nil, [node(:float, "1.33")])
    assert parse("1.33") == root

    root = node(:root, nil,
                [node(:symbol, "nilo"),
                 node(:symbol, "truthy"),
                 node(:symbol, "falsey")])
    assert parse("nilo truthy falsey") == root

    root = node(:root, nil,
                [node(:keyword, "nilo"),
                 node(:string, "truthy"),
                 node(:keyword, "falsey")])
    assert parse(":nilo \"truthy\" :falsey") == root
  end

  test "Map" do
    root = node(:root, nil, [node(:map, nil)])
    assert parse("{}") == root

    root = node(:root, nil,
                [node(:map, nil,
                      [node(:keyword, "name"),
                       node(:string, "John")])])
    assert parse("{:name \"John\"}") == root

    root = node(:root, nil,
                [node(:map, nil,
                      [node(:keyword, "name"),
                       node(:string, "John"),
                       node(:keyword, "age"),
                       node(:integer, "120")])])
    assert parse("{:name \"John\", :age 120}") == root

    assert_raise Ex.UnevenExpressionCountError, fn ->
      parse("{nil true false}")
    end

     assert_raise Ex.UnbalancedDelimiterError, fn ->
      parse("{nil true  ")
    end
  end

  test "Vector" do
    root = node(:root, nil, [node(:vector, nil)])
    assert parse("[]") == root

    root = node(:root, nil,
                [node(:vector, nil,
                      [node(:keyword, "name"),
                       node(:string, "John")])])
    assert parse("[:name, \"John\"]") == root

    root = node(:root, nil,
                [node(:vector, nil,
                      [node(:keyword, "name"),
                       node(:string, "John"),
                       node(:integer, "120")])])
    assert parse("[:name, \"John\", 120]") == root

    assert_raise Ex.UnbalancedDelimiterError, fn ->
      parse("[nil true false ")
    end
  end

  defp node(type, value, children \\ []) do
    %Parser.Node{type: type, value: value, children: children}
  end
end
