defmodule ExEdn do
  import ExEdn.Parser

  @moduledoc """
  Provides functions to `encode/1` and `decode/2` between *Elixir* and
  *edn* data format.
  """

  alias ExEdn.Encode
  alias ExEdn.Decode
  alias ExEdn.Exception, as: Ex

  @default_handlers %{"inst" => &ExEdn.Tag.inst/1,
                      "uuid" => &ExEdn.Tag.uuid/1}

  @doc """
  Encodes an *Elixir* term that implements the `ExEdn.Encode` protocol.
  When the term is a nested data structure (e.g. `List`, `Map`, etc.),
  all children should also implement `ExEdn.Encode` protocol for the
  encoding to be successful.

  There is an implementation for the most common *Elixir* data types:

  - `Atom`
  - `BitString` (binary)
  - `Integer`
  - `Float`
  - `Map`
  - `List`
  - `HashSet`

  There are also implementations for the following custom *Elixir* data
  types in order to support native *edn* types:

  - `ExEdn.Symbol`
  - `ExEdn.Character`
  - `Array` (vector)
  - `ExEdn.Tag` (tagged value)

  Since the *edn* specification requires every implementation to
  provide handlers for tags `uuid` and `inst`, the following data
  types also have an implementation for `ExEdn.Encode`:

  - `ExEdn.UUID` (`#uuid`)
  - `Timex.DatetTime` (`#inst`)

  ## Examples

      iex> ExEdn.encode([1, 2])
      {:ok, "(1, 2)"}

      iex> ExEdn.encode(%{a: 1, b: 2, c: 3})
      {:ok, "{:a 1, :b 2, :c 3}"}

      iex> ExEdn.encode({:a, 1})
      {:error, Protocol.UndefinedError}
  """
  @spec encode(Encode.t) :: {:ok, String.t} | {:error, atom}
  def encode(data) do
    try do
      {:ok, encode!(data)}
    rescue
      e -> {:error, e.__struct__}
    end
  end

  @doc """
  Same as `encode/1` but raises an error if the term could not
  be encoded.

  Returns the function result otherwise.
  """
  @spec encode!(Encode.t) :: String.t
  def encode!(data) do
    Encode.encode(data)
  end

  @doc """
  Decodes a string containing *edn* data into *Elixir* data
  structures. For a detailed list on the mapping between
  *edn* and *Elixir* check the documentation in the project's
  [page](https://github.com/jfacorro/ExEdn).

  When the string contains a single expression it is decoded
  and returned. Otherwise, if there are multiple expressions,
  then a list with all parsed expressions is returned.

  ## Examples

      iex> ExEdn.decode("{:a 1 :b 2}")
      {:ok, %{a: 1, b: 2}}

      iex> ExEdn.decode("(hello :world \\!)")
      {:ok, [%ExEdn.Symbol{name: "hello"}, :world, %ExEdn.Character{char: "!"}]

      iex> ExEdn.decode("[1 2 3 4]")
      {:ok, #Array<[1, 2, 3, 4], fixed=false, default=nil>}

      iex> ExEdn.decode("nil true false")
      {:ok, #Array<[1, 2, 3, 4], fixed=false, default=nil>}

      iex> ExEdn.decode("nil true false .")
      {:error, ExEdn.Exception.UnexpectedInputError}
  """
  @spec decode(String.t, Keyword.t) :: {:ok, any} | {:error, atom}
  def decode(input, opts \\ []) do
    try do
      {:ok, decode!(input, opts)}
    rescue
      e -> {:error, e.__struct__}
    end
  end

  @doc """
  Same as `decode/1` but raises an error if the term could not
  be encoded.

  Returns the function result otherwise.
  """
  @spec decode!(String.t, Keyword.t) :: any
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
