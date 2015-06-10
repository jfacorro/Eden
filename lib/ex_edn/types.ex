defmodule ExEdn.Character do
  defstruct char: nil

  def new(char), do: %ExEdn.Character{char: char}
end

defmodule ExEdn.Symbol do
  defstruct name: nil

  def new(name), do: %ExEdn.Symbol{name: name}
end

defmodule ExEdn.UUID do
  defstruct value: nil

  def new(value), do: %ExEdn.UUID{value: value}
end

defmodule ExEdn.Tag do
  defstruct name: nil, value: nil

  def new(name, value), do: %ExEdn.Tag{name: name, value: value}

  def inst(datetime) do
    Timex.DateFormat.parse!(datetime, "{RFC3339z}")
  end

  def uuid(value), do: %ExEdn.UUID{value: value}
end
