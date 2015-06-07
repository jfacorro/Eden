defmodule ExEdn.Exception do

  ## Lexer Exceptions

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

  ## Parser Exceptions

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

  defmodule IncompleteTagError do
    defexception [:message]
    def exception(msg) do
      %IncompleteTagError{message: "#{inspect msg}"}
    end
  end

  defmodule MissingDiscardExpressionError do
    defexception [:message]
    def exception(msg) do
      %MissingDiscardExpressionError{message: "#{inspect msg}"}
    end
  end
end
