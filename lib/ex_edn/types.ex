defmodule ExEdn.Character do
  defstruct char: nil
end

defmodule ExEdn.Symbol do
  defstruct name: nil
end

defmodule ExEdn.UUID do
  defstruct value: nil
end

defmodule ExEdn.Tag do
  defstruct name: nil, value: nil

  def inst(datetime) do
    Timex.DateFormat.parse(datetime, "{RFC3339z}")
  end

  def uuid(value), do: %ExEdn.UUID{value: value}
end
