defmodule ExEdn.Parser do
  alias ExEdn.Lexer
  alias ExEdn.Parser.Node
  require Logger

  defmodule UnexpectedTokenError do
    defexception [:message]

    def exception(msg) do
      %UnexpectedTokenError{message: "#{inspect msg}"}
    end
  end

  defmodule UnbalancedDelimiterError do
    defexception [:message]

    def exception(msg) do
      %UnbalancedDelimiterError{message: "#{inspect msg}"}
    end
  end

  defmodule UnevenExpressionCountError do
    defexception [:message]

    def exception(msg) do
      %UnevenExpressionCountError{message: "#{inspect msg}"}
    end
  end

  def parse(input) when is_binary(input) do
    tokens = Lexer.tokenize(input)
    parse(tokens)
  end
  def parse(tokens) when is_list(tokens) do
    state = %{tokens: tokens, node: new_node(:root)}
    exprs(state)
  end

  defp exprs(state) do
    state
    |> expr
    |> skip_when_nil(&exprs/1)
    |> when_nil(Node.reverse_children(state.node))
  end

  defp expr(%{tokens: []}) do
    nil
  end
  defp expr(state) do
    Logger.debug "EXPR #{inspect state.tokens}"
    terminal(state, :nil)
    || terminal(state, :false)
    || terminal(state, :true)
    || terminal(state, :symbol)
    || terminal(state, :keyword)
    || terminal(state, :integer)
    || terminal(state, :float)
    || map_begin(state)
  end

  defp terminal(state, type) do
    IO.puts "TERMINAL #{inspect type}"
    {state, token} = pop_token(state)
    if token?(token, type) do
      node = new_node(type, token.value, [])
      add_node(state, node)
    end
  end

  defp map_begin(state) do
    Logger.debug "MAP BEGIN"
    {state, token} = pop_token(state)
    if token?(token, :curly_open) do
      new_state = state
      |> set_node(new_node(:map))
      |> pairs
      |> map_end
      |> restore_node(state)
    end
  end

  defp pairs(state) do
    Logger.debug "PAIRS"
    state
    |> pair
    |> skip_when_nil(&pairs/1)
    |> when_nil(state)
  end
  defp pair(state) do
    Logger.debug "PAIR"
    state1 = expr(state)
    if state1 do
      state2 = expr(state1)
      if is_nil(state2) do
        raise UnevenExpressionCountError, state
      end
      state2
    end
  end

  defp map_end(state) do
    Logger.debug "MAP END"
    {state, token} = pop_token(state)
    if not token?(token, :curly_close) do
      raise UnbalancedDelimiterError, state.node
    end
    state
  end

  ##############################################################################
  ## Helper functions
  ##############################################################################

  ## Node

  defp new_node(type, value \\ nil, children \\ []) do
    %Node{type: type, value: value, children: children}
  end

  defp add_node(state, node) do
    update_in(state, [:node, :children], fn children ->
      [node | children]
    end)
  end

  defp set_node(state, node) do
    Map.put(state, :node, node)
  end

  defp restore_node(new_state, old_state) do
    child_node = Node.reverse_children(new_state.node)
    old_state = Map.put(new_state, :node, old_state.node)
    add_node(old_state, child_node)
  end

  ## Token

  defp token?(nil, _), do: false
  defp token?(token, type), do: (token.type == type)

  defp pop_token(state) do
    {update_in(state, [:tokens], &tail/1),
     List.first(state.tokens)}
  end

  ## Utils

  defp when_nil(nil, y), do: y
  defp when_nil(x, _), do: x

  defp skip_when_nil(nil, _), do: nil
  defp skip_when_nil(x, fun), do: fun.(x)

  defp tail([]), do: []
  defp tail(list), do: tl(list)
end
