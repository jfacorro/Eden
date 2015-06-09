defmodule ExEdn.Character do
  defstruct char: nil
end

defmodule ExEdn.Symbol do
  defstruct name: nil
end

defmodule ExEdn.Tag do
  defstruct name: nil, value: nil

  def inst(value) do
    Timex.DateFormat.parse(value, "{RFC3339z}")
  end

  def uuid(value), do: value
end
