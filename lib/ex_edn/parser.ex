defmodule ExEdn.Parser do
  alias ExEdn.Lexer
  alias ExEdn.Parser.Node
  alias ExEdn.Parser.Errors

  require Logger

  def parse(input) when is_binary(input) do
    tokens = Lexer.tokenize(input)
    parse(tokens)
  end
  def parse(tokens) when is_list(tokens) do
    state = %{tokens: tokens, node: new_node(:root)}
    state = exprs(state)
    Node.reverse_children(state.node)
  end

  ##############################################################################
  ## Rules and Productions
  ##############################################################################

  defp exprs(state) do
    ## TODO: throw UnexpectedToken when expr returns nil
    ##       but there are still tokens left to process.
    state
    |> expr
    |> skip_when_nil(&exprs/1)
    |> when_nil(state)
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
  end

  defp terminal(state, type) do
    Logger.debug "TERMINAL #{inspect type}"
    {state, token} = pop_token(state)
    if token?(token, type) do
      node = new_node(type, token.value, [])
      add_node(state, node)
    end
  end

  ## Map

  defp map_begin(state) do
    Logger.debug "MAP BEGIN"
    {state, token} = pop_token(state)
    if token?(token, :curly_open) do
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
    |> skip_when_nil(&pairs/1)
    |> when_nil(state)
  end

  defp pair(state) do
    Logger.debug "PAIR"
    state
    |> expr
    |> skip_when_nil(&pair2/1)
  end

  defp pair2(state) do
    state
    |> expr
    |> raise_when_nil(Errors.UnevenExpressionCountError, state)
  end

  defp map_end(state) do
    Logger.debug "MAP END"
    {state, token} = pop_token(state)
    if not token?(token, :curly_close) do
      raise Errors.UnbalancedDelimiterError, state.node
    end
    state
  end

  ## Vector

  defp vector_begin(state) do
    Logger.debug "VECTOR BEGIN"
    {state, token} = pop_token(state)
    if token?(token, :bracket_open) do
      state
      |> set_node(new_node(:vector))
      |> exprs
      |> vector_end
      |> restore_node(state)
    end
  end

  defp vector_end(state) do
    Logger.debug "VECTOR END #{inspect state.tokens}"
    {state, token} = pop_token(state)
    if not token?(token, :bracket_close) do
      raise Errors.UnbalancedDelimiterError, state.node
    end
    state
  end

  ## List

  defp list_begin(state) do
    Logger.debug "LIST BEGIN"
    {state, token} = pop_token(state)
    if token?(token, :paren_open) do
      state
      |> set_node(new_node(:list))
      |> exprs
      |> list_end
      |> restore_node(state)
    end
  end

  defp list_end(state) do
    Logger.debug "LIST END #{inspect state.tokens}"
    {state, token} = pop_token(state)
    if not token?(token, :paren_close) do
      raise Errors.UnbalancedDelimiterError, state.node
    end
    state
  end

  ## Tag

  defp tag(state) do
    Logger.debug "TAG"
    {state, token} = pop_token(state)
    if token?(token, :tag) do
      state
      |> set_node(new_node(:tag))
      |> expr
      |> raise_when_nil(Errors.IncompleteTagError, state)
      |> restore_node(state)
    end
  end

  ## Discard

  defp discard(state) do
    Logger.debug "DISCARD"
    {state, token} = pop_token(state)
    if token?(token, :discard) do
      state
      |> set_node(new_node(:discard))
      |> expr
      |> raise_when_nil(Errors.MissingDiscardExpressionError, state)
      |> restore_node(state, false)
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

  defp when_nil(nil, y), do: y
  defp when_nil(x, _), do: x

  defp skip_when_nil(nil, _), do: nil
  defp skip_when_nil(x, fun), do: fun.(x)

  defp raise_when_nil(nil, ex, msg), do: (raise ex, msg)
  defp raise_when_nil(x, _, _), do: x


  defp tail([]), do: []
  defp tail(list), do: tl(list)
end
