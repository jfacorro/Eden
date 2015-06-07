defmodule ExEdn.Parser.Node do
  defstruct type: nil, value: nil, children: []

  defimpl Access, for: __MODULE__ do
    def get(node, key) do
      :maps.get(key, node)
    end
    def get_and_update(node, key, fun) do
      {get, update} = fun.(:maps.get(key, node))
      {get, :maps.put(key, update, node)}
    end
  end

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect(node, opts) do
      type_str = Atom.to_string(node.type)
      value_str = node.value || "nil"

      level = Map.get(opts, :level, 0)
      opts = Map.put(opts, :level, level + 2)
      padding = String.duplicate(" ", level)

      concat [padding, "Node[",type_str , ",", value_str, "]\n"]
              ++ Enum.map(node.children, fn x -> to_doc(x, opts)end )
    end
  end

  def reverse_children(node) do
    update_in(node, [:children], &Enum.reverse/1)
  end
end
