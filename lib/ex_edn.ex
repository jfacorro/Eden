defmodule ExEdn do
  import ExEdn.Parser
  alias ExEdn.Decode
  alias ExEdn.Exception, as: Ex

  @default_handlers %{"inst" => &ExEdn.Tag.inst/1,
                      "uuid" => &ExEdn.Tag.uuid/1}

  def encode(_data) do
    raise Ex.NotImplementedError, __ENV__.function
  end

  def encode!(_data) do
    raise Ex.NotImplementedError, __ENV__.function
  end

  def decode(input) do
    try do
      {:ok, decode!(input)}
    rescue
      e -> {:error, e.__struct__}
    end
  end

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
