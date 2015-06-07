defmodule ExEdn.Lexer do
  alias ExEdn.Exception, as: Ex

  defmodule Token do
    defstruct type: nil, value: nil
  end

  ##############################################################################
  ## API
  ##############################################################################

  @doc """
  Takes a string and returns a list of Token structs.
  """
  def tokenize(input) do
    initial_state = %{state: :new, tokens: [], current: nil}
    _tokenize(initial_state, input)
  end

  ##############################################################################
  ## Private functions
  ##############################################################################

  # End of input
  defp _tokenize(state, <<>>) do
    state
    |> valid?
    |> add_token(state.current)
    |> Map.get(:tokens)
    |> Enum.reverse
  end

 # Comment
  defp _tokenize(state = %{state: :new}, <<";", rest :: binary>>) do
    token = token(:comment, "")
    start_token(state, :comment, token, rest)
  end
  defp _tokenize(state = %{state: :comment}, <<char :: utf8, rest :: binary>>)
  when <<char>> in ["\n", "\r"] do
    end_token(state, rest)
  end
  defp _tokenize(state = %{state: :comment}, <<";", rest :: binary>>) do
    _tokenize(state, rest)
  end
  defp _tokenize(state = %{state: :comment}, <<char :: utf8, rest :: binary>>) do
    consume_char(state, <<char>>, rest)
  end

  # Literals
  defp _tokenize(state = %{state: :new}, <<"nil", rest :: binary>>) do
    token = token(:nil, "nil")
    start_token(state, :check_literal, token, rest)
  end
  defp _tokenize(state = %{state: :new}, <<"true", rest :: binary>>) do
    token = token(:true, "true")
    start_token(state, :check_literal, token, rest)
  end
  defp _tokenize(state = %{state: :new}, <<"false", rest :: binary>>) do
    token = token(:false, "false")
    start_token(state, :check_literal, token, rest)
  end
  defp _tokenize(state = %{state: :check_literal}, <<char :: utf8, rest :: binary>>) do
    if separator?(<<char>>) do
      end_token(state, <<char>> <> rest)
    else
      token = token(:symbol, state.current.value <> <<char>>)
      start_token(state, :symbol, token, rest)
    end
  end

  # String
  defp _tokenize(state = %{state: :new}, <<"\"", rest :: binary>>) do
    token = token(:string, "")
    start_token(state, :string, token, rest)
  end
  defp _tokenize(state = %{state: :string}, <<"\\", char :: utf8, rest :: binary>>) do
      consume_char(state, escaped_char(<<char>>), rest)
  end
  defp _tokenize(state = %{state: :string}, <<"\"" :: utf8, rest :: binary>>) do
    end_token(state, rest)
  end
  defp _tokenize(state = %{state: :string}, <<char :: utf8, rest :: binary>>) do
    consume_char(state, <<char>>, rest)
  end

  # Character
  defp _tokenize(state = %{state: :new}, <<"\\", char :: utf8, rest :: binary>>) do
    token = token(:character, <<char>>)
    end_token(state, token, rest)
  end

  # Keyword and Symbol
  defp _tokenize(state = %{state: :new}, <<":", rest :: binary>>) do
    token = token(:keyword, "")
    start_token(state, :symbol, token, rest)
  end
  defp _tokenize(state = %{state: :symbol}, <<"/", rest :: binary>>) do
    if not String.contains?(state.current.value, "/") do
      consume_char(state, "/", rest)
    else
      raise Ex.UnexpectedInputError, "/"
    end
  end
  defp _tokenize(state = %{state: :symbol}, <<c :: utf8, rest :: binary>> = input) do
    if symbol_char?(<<c>>) do
      consume_char(state, <<c>>, rest)
    else
      end_token(state, input)
    end
  end

  # Integers & Float
  defp _tokenize(state = %{state: :new}, <<sign :: utf8, rest :: binary>>)
  when <<sign>> in ["-", "+"] do
    token = token(:integer, <<sign>>)
    start_token(state, :number, token, rest)
  end
  defp _tokenize(state = %{state: :exponent}, <<sign :: utf8, rest :: binary>>)
  when <<sign>> in ["-", "+"] do
    consume_char(state, <<sign>>, rest)
  end
  defp _tokenize(state = %{state: :number}, <<"N", rest :: binary>>) do
    state = append_to_current(state, "N")
    end_token(state, rest)
  end
  defp _tokenize(state = %{state: :number}, <<"M", rest :: binary>>) do
    state = append_to_current(state, "M")
    token = token(:float, state.current.value)
    end_token(state, token, rest)
  end
  defp _tokenize(state = %{state: :number}, <<".", rest :: binary>>) do
    state = append_to_current(state, ".")
    token = token(:float, state.current.value)
    start_token(state, :fraction, token, rest)
  end
  defp _tokenize(state = %{state: :number}, <<char :: utf8, rest :: binary>>)
  when <<char>> in ["e", "E"] do
    state = append_to_current(state, <<char>>)
    token = token(:float, state.current.value)
    start_token(state, :exponent, token, rest)
  end
  defp _tokenize(state = %{state: s}, <<char :: utf8, rest :: binary>> = input)
  when s in [:number, :exponent, :fraction] do
    cond do
      digit?(<<char>>) ->
        state
        |> set_state(:number)
        |> consume_char(<<char>>, rest)
      s in [:exponent, :fraction] and separator?(<<char>>) ->
        raise Ex.UnfinishedTokenError, state.current
      separator?(<<char>>) ->
        end_token(state, input)
      true ->
        raise Ex.UnexpectedInputError, <<char>>
    end
  end

  # Delimiters
  defp _tokenize(state = %{state: :new}, <<delim :: utf8, rest :: binary>>)
  when <<delim>> in ["{", "}", "[", "]", "(", ")"] do
    delim = <<delim>>
    token = token(delim_type(delim), delim)
    end_token(state, token, rest)
  end
  defp _tokenize(state = %{state: :new}, <<"#\{", rest :: binary>>) do
    token = token(:set_open, "#\{")
    end_token(state, token, rest)
  end

  # Whitespace
  defp _tokenize(state = %{state: :new}, <<whitespace :: utf8, rest :: binary>>)
  when <<whitespace>> in [" ", "\t", "\r", "\n", ","] do
    _tokenize(state, rest)
  end

  # Discard
  defp _tokenize(state = %{state: :new}, <<"#_", rest :: binary>>) do
    token = token(:discard, "#_")
    end_token(state, token, rest)
  end

  # Tags
  defp _tokenize(state = %{state: :new}, <<"#", rest :: binary>>) do
    token = token(:tag, "")
    start_token(state, :symbol, token, rest)
  end

  # Symbol, Integer or Invalid input
  defp _tokenize(state = %{state: :new}, <<char :: utf8, rest :: binary>>) do
    cond do
      alpha?(<<char>>) ->
        token = token(:symbol, <<char>>)
        start_token(state, :symbol, token, rest)
      digit?(<<char>>) ->
        token = token(:integer, <<char>>)
        start_token(state, :number, token, rest)
      true ->
        raise Ex.UnexpectedInputError, <<char>>
    end
  end

  # Unexpected Input
  defp _tokenize(_, <<char :: utf8, _ :: binary>>) do
    raise Ex.UnexpectedInputError, <<char>>
  end

  ##############################################################################
  ## Helper functions
  ##############################################################################

  defp start_token(state, name, token, rest) do
    state
    |> Map.merge(%{state: name, current: token})
    |> _tokenize(rest)
  end

  defp consume_char(state, char, rest) when is_binary(char) do
    state
    |> append_to_current(char)
    |> _tokenize(rest)
  end

  defp end_token(state, rest) do
    state
    |> add_token(state.current)
    |> reset
    |> _tokenize(rest)
  end

  defp end_token(state, token, rest) do
    state
    |> set_token(token)
    |> end_token(rest)
  end

  defp token(type, value) do
    %Token{type: type, value: value}
  end

  defp set_token(state, token) do
    Map.put(state, :current, token)
  end

  defp set_state(state, name) do
    Map.put(state, :state, name)
  end

  defp append_to_current(%{current: current} = state, c) do
    current = %{current | value: current.value <> c}
    %{state | current: current}
  end

  defp reset(state) do
    %{state |
      state: :new,
      current: nil}
  end

  defp valid?(%{state: state, current: current})
  when state in [:string, :exponent, :character, :fraction] do
    raise Ex.UnfinishedTokenError, current
  end
  defp valid?(state) do
    state
  end

  defp add_token(state, nil) do
    state
  end
  defp add_token(state, token) do
    %{state | tokens: [token | state.tokens]}
  end

  defp delim_type("{"), do: :curly_open
  defp delim_type("}"), do: :curly_close
  defp delim_type("["), do: :bracket_open
  defp delim_type("]"), do: :bracket_close
  defp delim_type("("), do: :paren_open
  defp delim_type(")"), do: :paren_close

  defp escaped_char("\""), do: "\""
  defp escaped_char("t"), do: "\t"
  defp escaped_char("r"), do: "\r"
  defp escaped_char("n"), do: "\n"
  defp escaped_char("\\"), do: "\\"

  defp alpha?(char), do: String.match?(char, ~r/[a-zA-Z]/)

  defp digit?(char), do: String.match?(char, ~r/[0-9]/)

  defp symbol_char?(char), do: String.match?(char, ~r/[_a-zA-Z0-9.*+!-?$%&=<>\#:]/)

  defp whitespace?(char), do: String.match?(char, ~r/[\s,]/)

  defp delim?(char), do: String.match?(char, ~r/[\{\}\[\]\(\)]/)

  defp separator?(char), do: whitespace?(char) or delim?(char)
end
