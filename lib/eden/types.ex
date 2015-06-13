defmodule Eden.Character do
  defstruct char: nil

  def new(char), do: %Eden.Character{char: char}
end

defmodule Eden.Symbol do
  defstruct name: nil

  def new(name), do: %Eden.Symbol{name: name}
end

defmodule Eden.UUID do
  defstruct value: nil

  def new(value), do: %Eden.UUID{value: value}
end

defmodule Eden.Tag do
  defstruct name: nil, value: nil

  def new(name, value), do: %Eden.Tag{name: name, value: value}

  def inst(datetime) do
    Timex.DateFormat.parse!(datetime, "{RFC3339z}")
  end

  def uuid(value), do: %Eden.UUID{value: value}
end
