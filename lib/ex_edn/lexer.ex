defmodule ExEdn.Lexer do
  defmodule Token do
    defstruct type: nil, value: nil
  end

  defmodule UnexpectedInputError do
    defexception [:message]

    def exception(msg) do
      %UnexpectedInputError{message: msg}
    end
  end

  defmodule UnfinishedTokenError do
    defexception [:message]

    def exception(msg) do
      %UnfinishedTokenError{message: "#{inspect msg}"}
    end
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

  # Literals
  defp _tokenize(state = %{state: :new}, <<"nil", rest :: binary>>) do
    check_literal(state, :nil, rest)
  end
  defp _tokenize(state = %{state: :new}, <<"true", rest :: binary>>) do
    check_literal(state, :true, rest)
  end
  defp _tokenize(state = %{state: :new}, <<"false", rest :: binary>>) do
    check_literal(state, :false, rest)
  end

  # String
  defp _tokenize(state = %{state: :new}, <<"\"", rest :: binary>>) do
    token = token(:string, "")
    state
    |> Map.merge(%{state: :string, current: token})
    |> _tokenize(rest)
  end
  defp _tokenize(state = %{state: :string}, <<"\\", char :: utf8, rest :: binary>>) do
      state
      |> append_to_current(escaped_char(<<char>>))
      |> _tokenize(rest)
  end
  defp _tokenize(state = %{state: :string}, <<"\"" :: utf8, rest :: binary>>) do
    state
    |> add_token(state.current)
    |> reset
    |> _tokenize(rest)
  end
  defp _tokenize(state = %{state: :string}, <<c :: utf8, rest :: binary>>) do
      state
      |> append_to_current(<<c>>)
      |> _tokenize(rest)
  end

  # Character
  defp _tokenize(state = %{state: :new}, <<"\\", char :: utf8, rest :: binary>>) do
    token = token(:character, <<char>>)
    state
    |> add_token(token)
    |> _tokenize(rest)
  end

  # Keyword and Symbol
  defp _tokenize(state = %{state: :new}, <<":", rest :: binary>>) do
    token = token(:keyword, "")
    state
    |> Map.merge(%{state: :symbol, current: token})
    |> _tokenize(rest)
  end
  defp _tokenize(state = %{state: :symbol}, <<"/", rest :: binary>>) do
    if not String.contains?(state.current.value, "/") do
      state
      |> append_to_current("/")
      |> _tokenize(rest)
    else
      raise UnexpectedInputError, "/"
    end
  end
  defp _tokenize(state = %{state: :symbol}, <<c :: utf8, rest :: binary>> = input) do
    if symbol_char?(<<c>>) do
      state
      |> append_to_current(<<c>>)
      |> _tokenize(rest)
    else
      state
      |> add_token(state.current)
      |> reset
      |> _tokenize(input)
    end
  end

  # Integers & Float
  defp _tokenize(state = %{state: :new}, <<sign :: utf8, rest :: binary>>)
  when <<sign>> in ["-", "+"] do
    token = token(:integer, <<sign>>)
    state
    |> Map.merge(%{state: :number, current: token})
    |> _tokenize(rest)
  end
  defp _tokenize(state = %{state: :exponent}, <<sign :: utf8, rest :: binary>>)
  when <<sign>> in ["-", "+"] do
    state
    |> append_to_current(<<sign>>)
    |> _tokenize(rest)
  end
  defp _tokenize(state = %{state: :number}, <<"N", rest :: binary>>) do
    state = append_to_current(state, "N")
    state
    |> add_token(state.current)
    |> reset
    |> _tokenize(rest)
  end
  defp _tokenize(state = %{state: :number}, <<"M", rest :: binary>>) do
    state = append_to_current(state, "M")
    token = token(:float, state.current.value)
    state
    |> add_token(token)
    |> reset
    |> _tokenize(rest)
  end
  defp _tokenize(state = %{state: :number}, <<".", rest :: binary>>) do
    state = append_to_current(state, ".")
    token = token(:float, state.current.value)
    state
    |> Map.merge(%{state: :fraction, current: token})
    |> _tokenize(rest)
  end
  defp _tokenize(state = %{state: :number}, <<char :: utf8, rest :: binary>>)
  when <<char>> in ["e", "E"] do
    state = append_to_current(state, <<char>>)
    token = token(:float, state.current.value)
    state
    |> Map.merge(%{state: :exponent, current: token})
    |> _tokenize(rest)
  end
  defp _tokenize(state = %{state: s}, <<char :: utf8, rest :: binary>> = input)
  when s in [:number, :exponent, :fraction] do
    cond do
      digit?(<<char>>) ->
        state
        |> Map.merge(%{state: :number})
        |> append_to_current(<<char>>)
        |> _tokenize(rest)
      s in [:exponent, :fraction] and separator?(<<char>>) ->
        raise UnfinishedTokenError, state.current
      separator?(<<char>>) ->
        state
        |> add_token(state.current)
        |> reset
        |> _tokenize(input)
      true ->
        raise UnexpectedInputError, <<char>>
    end
  end

  # Delimiters
  defp _tokenize(state = %{state: :new}, <<delim :: utf8, rest :: binary>>)
  when <<delim>> in ["{", "}", "[", "]", "(", ")"] do
    delim = <<delim>>
    token = token(delim_type(delim), delim)
    state
    |> add_token(token)
    |> _tokenize(rest)
  end
  defp _tokenize(state = %{state: :new}, <<"#\{", rest :: binary>>) do
    token = token(:set_open, "#\{")
    state
    |> add_token(token)
    |> _tokenize(rest)
  end

  # Whitespace
  defp _tokenize(state = %{state: :new}, <<whitespace :: utf8, rest :: binary>>)
  when <<whitespace>> in [" ", "\t", "\r", "\n", ","] do
    _tokenize(state, rest)
  end

  # Discard
  defp _tokenize(state = %{state: :new}, <<"#_", rest :: binary>>) do
    token = token(:discard, "#_")
    state
    |> add_token(token)
    |> _tokenize(rest)
  end

  # Tags
  defp _tokenize(state = %{state: :new}, <<"#", rest :: binary>>) do
    token = token(:tag, "")
    state
    |> Map.merge(%{state: :symbol, current: token})
    |> _tokenize(rest)
  end

  # Symbol, Integer or Invalid input
  defp _tokenize(state = %{state: :new}, <<char :: utf8, rest :: binary>>) do
    cond do
      alpha?(<<char>>) ->
        token = token(:symbol, <<char>>)
        state
        |> Map.merge(%{state: :symbol, current: token})
        |> _tokenize(rest)
      digit?(<<char>>) ->
        token = token(:integer, <<char>>)
        state
        |> Map.merge(%{state: :number, current: token})
        |> _tokenize(rest)
      true ->
        raise UnexpectedInputError, <<char>>
    end
  end

  # Unexpected Input
  defp _tokenize(_, <<char :: utf8, _ :: binary>>) do
    raise UnexpectedInputError, <<char>>
  end

  ##############################################################################
  ## Helper functions
  ##############################################################################

  defp token(type, value) do
    %Token{type: type, value: value}
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
    raise UnfinishedTokenError, current
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

  defp check_literal(state, type, <<>>) do
    value = Atom.to_string(type)
    state
    |> add_token(token(type, value))
    |> _tokenize(<<>>)
  end
  defp check_literal(state, type, <<char :: utf8, rest :: binary>>) do
    value = Atom.to_string(type)
    if separator?(<<char>>) do
      state
      |> add_token(token(type, value))
      |> _tokenize(<<char>> <> rest)
    else
      token = token(:symbol, value <> <<char>>)
      state
      |> Map.merge(%{state: :symbol, current: token})
      |> _tokenize(rest)
    end
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
