defmodule ExEdn.Parser do
  alias ExEdn.Lexer
  alias ExEdn.Parser.Node

  defmodule UnexpectedTokenError do
    defexception [:message]

    def exception(msg) do
      %UnexpectedTokenError{message: "#{inspect msg}"}
    end
  end

  defmodule UnbalancedMapError do
    defexception [:message]

    def exception(msg) do
      %UnbalancedMapError{message: "#{inspect msg}"}
    end
  end

  def parse(input) when is_binary(input) do
    tokens = Lexer.tokenize(input)
    parse(tokens)
  end
  def parse(tokens) when is_list(tokens) do
    state = %{tokens: tokens, node: new_node(:root)}
    expr(state)
  end

  defp expr(%{tokens: [], node: node}) do
    update_in(node, [:children], &Enum.reverse/1)
  end
  defp expr(state) do
    IO.puts "EXPR #{inspect state}"
    new_state =
       terminal(state, :nil)
    || terminal(state, :false)
    || terminal(state, :true)
    || terminal(state, :symbol)
    || terminal(state, :keyword)
    || terminal(state, :integer)
    || terminal(state, :float)
    || map_begin(state)

    if is_nil(new_state) do
      {_, token} = pop_token(state)
      raise UnexpectedTokenError, token
    end

    expr(new_state)
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
    IO.puts "MAP BEGIN"
    {state, token} = pop_token(state)
    if token?(token, :curly_open) do
      map_node = new_node(:map)
      new_state = state
      |> Map.put(:node, map_node)
      |> pairs
      |> map_end

      state = Map.put(new_state, :node, state.node)
      add_node(state, map_node)
    end
  end

  defp pairs(state) do
    IO.puts "PAIRS"
    if state do
      state
      |> pair
      |> pairs
      |> when_nil(state)
    end
  end
  defp pair(state) do
    IO.puts "PAIR"
    state1 = expr(state)
    if state1 do
      state2 = expr(state1)
      if not state2 do
        raise UnevenExpressionCountError, state
      end
    end
  end

  defp map_end(state) do
    IO.puts "MAP END #{inspect state}"
    {state, token} = pop_token(state)
    if not token?(token, :curly_close) do
      raise UnbalancedMapError, state.node
    end
    state
  end

  defp pop_token(state) do
    {update_in(state, [:tokens], &tl/1),
     List.first(state.tokens)}
  end

  defp add_node(state, node) do
    update_in(state, [:node, :children], fn children ->
      [node | children]
    end)
  end

  defp token?(token, type), do: (token.type == type)

  defp new_node(type, value \\ nil, children \\ []) do
    %Node{type: type, value: value, children: children}
  end

  defp when_nil(nil, y), do: y
  defp when_nil(x, _), do: x
end
