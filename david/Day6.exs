defmodule Day6 do

  def parse_orbits(string) do 
    string
    |> String.split("\n")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.map(&String.split(&1, ")"))
    |> Stream.map(fn [a, b] -> {b, a} end)
    |> Map.new
  end

  def count_orbits(map) do
    count_depth = fn
      (nil, _) -> -1
      (key, f) -> 1 + f.(map[key], f)
    end
    map
    |> Map.keys()
    |> Stream.map(fn key -> count_depth.(key, count_depth) end)
    |> Enum.sum
  end

end
