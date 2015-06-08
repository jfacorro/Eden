defmodule ExEdn.Decode do
  alias ExEdn.Parser.Node
  alias ExEdn.Character
  alias ExEdn.Symbol
  require Integer

  def decode(children) when is_list(children) do
    Enum.map(children, &decode/1)
  end

  def decode(%Node{type: :root, children: children}) do
    decode(children)
  end
  def decode(%Node{type: :nil}) do
    :nil
  end
  def decode(%Node{type: :true}) do
    :true
  end
  def decode(%Node{type: :false}) do
    :false
  end
  def decode(%Node{type: :string, value: value}) do
    value
  end
  def decode(%Node{type: :character, value: value}) do
    %Character{char: value}
  end
  def decode(%Node{type: :symbol, value: value}) do
    %Symbol{name: value}
  end
  def decode(%Node{type: :keyword, value: value}) do
    String.to_atom(value)
  end
  def decode(%Node{type: :integer, value: value}) do
    :erlang.binary_to_integer(value)
  end
  def decode(%Node{type: :float, value: value}) do
    :erlang.binary_to_float(value)
  end
  def decode(%Node{type: :list, children: children}) do
    Enum.map(children, &decode/1)
  end
  def decode(%Node{type: :vector, children: children}) do
    children
    |> decode
    |> Array.from_list
  end
  def decode(%Node{type: :map, children: children} = node) do
    if Integer.is_odd(length children) do
      raise Ex.UnevenExpressionCountError, node
    end
    children
    |> decode
    |> Enum.chunk(2)
    |> Enum.map(fn [a, b] -> {a, b} end)
    |> Enum.into(%{})
  end
  def decode(%Node{type: :set, children: children}) do
    children
    |> decode
    |> Enum.reduce(HashSet.new, fn x, acc -> HashSet.put(acc, x) end)
  end
  def decode(%Node{type: :tag, children: [_]}) do
    raise "Tag decoding not implemented"
  end
  def decode(%Node{type: type}) do
    raise "Unrecognized node type: #{inspect type}"
  end
end
