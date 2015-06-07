defmodule ExEdn.Parser do
  alias ExEdn.Lexer
  alias ExEdn.Parser.Node
  alias ExEdn.Exception, as: Ex

  require Logger

  def parse(input) when is_binary(input) do
    tokens = Lexer.tokenize(input)
    parse(tokens)
  end
  def parse(tokens) when is_list(tokens) do
    state = %{tokens: tokens, node: new_node(:root)}
    state = exprs(state)
    if not Enum.empty?(state.tokens) do
      raise Ex.UnexpectedTokenError, List.first(state.tokens)
    end
    Node.reverse_children(state.node)
  end

  ##############################################################################
  ## Rules and Productions
  ##############################################################################

  defp exprs(state) do
    state
    |> expr
    |> skip_when(&exprs/1, &is_nil/1)
    |> return_when(state, &is_nil/1)
  end

  defp expr(%{tokens: []}) do
    nil
  end
  defp expr(state) do
    Logger.debug "EXPR"
    terminal(state, :nil)
    || terminal(state, :false)
    || terminal(state, :true)
    || terminal(state, :symbol)
    || terminal(state, :keyword)
    || terminal(state, :integer)
    || terminal(state, :float)
    || terminal(state, :string)
    || map_begin(state)
    || vector_begin(state)
    || list_begin(state)
    || tag(state)
    || discard(state)
    || comment(state)
  end

  defp terminal(state, type) do
    {state, token} = pop_token(state)
    if token?(token, type) do
      Logger.debug "TERMINAL #{inspect type}"
      node = new_node(type, token.value, [])
      add_node(state, node)
    end
  end

  ## Map

  defp map_begin(state) do
    {state, token} = pop_token(state)
    if token?(token, :curly_open) do
      Logger.debug "MAP BEGIN"
      state
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
    |> skip_when(&pairs/1, &is_nil/1)
    |> return_when(state, &is_nil/1)
  end

  defp pair(state) do
    Logger.debug "PAIR"
    state
    |> expr
    |> skip_when(&pair2/1, &is_nil/1)
  end

  defp pair2(state) do
    Logger.debug "PAIR2"
    state
    |> expr
    |> raise_when(Ex.UnevenExpressionCountError, state, &is_nil/1)
  end

  defp map_end(state) do
    {state, token} = pop_token(state)
    if not token?(token, :curly_close) do
      Logger.debug "MAP END"
      raise Ex.UnbalancedDelimiterError, state.node
    end
    state
  end

  ## Vector

  defp vector_begin(state) do
    {state, token} = pop_token(state)
    if token?(token, :bracket_open) do
      Logger.debug "VECTOR BEGIN"
      state
      |> set_node(new_node(:vector))
      |> exprs
      |> vector_end
      |> restore_node(state)
    end
  end

  defp vector_end(state) do
    {state, token} = pop_token(state)
    if not token?(token, :bracket_close) do
      Logger.debug "VECTOR END"
      raise Ex.UnbalancedDelimiterError, state.node
    end
    state
  end

  ## List

  defp list_begin(state) do
    {state, token} = pop_token(state)
    if token?(token, :paren_open) do
      Logger.debug "LIST BEGIN"
      state
      |> set_node(new_node(:list))
      |> exprs
      |> list_end
      |> restore_node(state)
    end
  end

  defp list_end(state) do
    {state, token} = pop_token(state)
    if not token?(token, :paren_close) do
      Logger.debug "LIST END"
      raise Ex.UnbalancedDelimiterError, state.node
    end
    state
  end

  ## Tag

  defp tag(state) do
    {state, token} = pop_token(state)
    if token?(token, :tag) do
      Logger.debug "TAG"
      state
      |> set_node(new_node(:tag, token.value))
      |> expr
      |> raise_when(Ex.IncompleteTagError, state, &is_nil/1)
      |> restore_node(state)
    end
  end

  ## Discard

  defp discard(state) do
    {state, token} = pop_token(state)
    if token?(token, :discard) do
      Logger.debug "DISCARD"
      state
      |> set_node(new_node(:discard))
      |> expr
      |> raise_when(Ex.MissingDiscardExpressionError, state, &is_nil/1)
      |> restore_node(state, false)
    end
  end

  ## Comment

  defp comment(state) do
    {state, token} = pop_token(state)
    if token?(token, :comment) do
      Logger.debug "COMMENT"
      state
    end
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

  defp restore_node(new_state, old_state, add_child? \\ true) do
    child_node = Node.reverse_children(new_state.node)
    old_state = Map.put(new_state, :node, old_state.node)
    if add_child? do
      add_node(old_state, child_node)
    else
      old_state
    end
  end

  ## Token

  defp token?(nil, _), do: false
  defp token?(token, type), do: (token.type == type)

  defp pop_token(state) do
    {update_in(state, [:tokens], &tail/1),
     List.first(state.tokens)}
  end

  ## Utils

  defp return_when(x, y, pred?) do
    if(pred?.(x), do: y, else: x)
  end

  defp skip_when(x, fun, pred?) do
    if(pred?.(x), do: x, else: fun.(x))
  end

  defp raise_when(x, ex, msg, pred?) do
    if(pred?.(x), do: (raise ex, msg), else: x)
  end

  defp tail([]), do: []
  defp tail(list), do: tl(list)
end
