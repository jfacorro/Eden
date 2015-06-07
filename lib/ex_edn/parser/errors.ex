defmodule ExEdn.Parser.Errors do
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
end
