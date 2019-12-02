defmodule Day1 do
  def requiredFuel(mass) do
    trunc(mass / 3) - 2
  end
  def totalRequiredFuel(mass) do
    Stream.iterate(mass, &requiredFuel/1)
    |> Stream.drop(1)
    |> Stream.take_while(&(&1 > 0))
    |> Enum.sum
  end
end
