defmodule Day17 do
  def print_map(m) when m == %{} do
    IO.puts("")
  end

  def print_map(map) do
    minX = (map |> Map.keys() |> Stream.map(fn {x, _} -> x end) |> Enum.min()) - 1
    minY = (map |> Map.keys() |> Stream.map(fn {_, y} -> y end) |> Enum.min()) - 1
    maxX = (map |> Map.keys() |> Stream.map(fn {x, _} -> x end) |> Enum.max()) + 1
    maxY = (map |> Map.keys() |> Stream.map(fn {_, y} -> y end) |> Enum.max()) + 1
    IO.puts maxY..minY
    |> Stream.flat_map(fn y ->
      minX..maxX
      |> Stream.map(fn x -> {x, y} end)
    end)
    |> Enum.reduce("\n", fn {x, y}, str ->
      char = case map |> Map.get({x, y}) do
          nil -> " "
          x -> x
        end
      if x == minX do
        str <> "\n" <> char
      else
        str <> char
      end
    end)
  end

  def read_state(state \\ %{}, {x, y} \\ {0, 0}, max_size \\ -1) do
#    print_map(state)
    if max_size == -1 || (state |> Enum.count()) < max_size do
      receive do
        input -> 
          case input do
            {:input, 35} -> read_state(state |> Map.put({x, y}, "#"), {x + 1, y})
            {:input, 46} -> read_state(state |> Map.put({x, y}, "."), {x + 1, y})
            {:input, 10} -> read_state(state, {0, y + 1})
            {:input, other} -> read_state(state |> Map.put({x, y}, <<other>>), {x + 1, y})
            _ -> state
          end
      end
    else
        print_map(state)
        read_state(%{}, {0, 0}, max_size)
    end
  end

  def neighbors({x, y}) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
  end
end
