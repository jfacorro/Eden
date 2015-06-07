defmodule ExEdn.Parser.Node do
  defstruct type: nil, value: nil, children: []

  defimpl Access, for: ExEdn.Parser.Node do
    def get(node, key) do
      :maps.get(key, node)
    end
    def get_and_update(node, key, fun) do
      {get, update} = fun.(:maps.get(key, node))
      {get, :maps.put(key, update, node)}
    end
  end
end
