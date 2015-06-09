defmodule ExEdn do
  import ExEdn.Parser
  alias ExEdn.Encode
  alias ExEdn.Decode
  alias ExEdn.Exception, as: Ex

  def encode(_data) do
    raise "Unimplemented function"
  end

  def encode!(data) do
    Encode.encode(data)
  end

  def decode(input) do
    try do
      {:ok, decode!(input)}
    rescue
      e -> {:error, e.__struct__}
    end
  end

  @default_handlers %{"inst" => &ExEdn.Tag.inst/1,
                      "uuid" => &ExEdn.Tag.uuid/1}

  def decode!(input, opts \\ []) do
    tree = parse(input, location: true)
    handlers = Map.merge(@default_handlers, opts[:handlers] || %{})
    opts = [handlers: handlers]
    case Decode.decode(tree, opts) do
      [] -> raise Ex.EmptyInputError, input
      [data] -> data
      data -> data
    end
  end
end
