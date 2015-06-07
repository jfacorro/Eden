defmodule ExEdn.LexerTest do
  use ExUnit.Case
  alias ExEdn.Parser
  alias ExEdn.Exception, as: Ex

  test "Whitespace" do
    assert Parser.parse(",,,  ") == node(:root, nil, [])
    assert Parser.parse(" \n \t, \r") == node(:root, nil, [])
  end

  defp node(type, value, children) do
    %Parser.Node{type: type, value: value, children: children}
  end
end
