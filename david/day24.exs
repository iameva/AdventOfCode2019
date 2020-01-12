use Bitwise
defmodule Day24 do
  def parse(str) do
    str
    |> String.to_charlist
    |> Stream.filter(&(&1 != ?\n))
    |> Stream.with_index
    |> Enum.reduce(0, fn {c, i}, r ->
      case c do
        ?# ->
          bor(r, 1 <<< i)
        _ ->
          r
      end
    end)
  end

  def print(state) do
    0..24
    |> Enum.reduce("", fn i, s ->
      str = if band(state, 1 <<< i) == 0 do
        s <> "."
      else
        s <> "#"
      end
      if rem(i, 5) == 4 do
        str <> "\n"
      else
        str
      end
    end)
    |> IO.write
  end

  def neighbors(i) do
    [i - 5, i + 5]
    ++ case rem(i, 5) do
      0 -> [i + 1]
      4 -> [i - 1]
      _ -> [i - 1, i + 1]
    end
  end

  def step(state) do
    0..24
    |> Enum.reduce(0, fn i, r ->
      num_nbrs =
        neighbors(i)
        |> Stream.map(fn n -> band(state >>> n, 1) end)
        |> Enum.sum
      if num_nbrs == 1 do
        bor(r, 1 <<< i)
      else
        if band(state >>> i, 1) == 0 && num_nbrs == 2 do
          bor(r, 1 <<< i)
        else
          r
        end
      end
    end)
  end

  def find_duplicate_state(state, old_states \\ MapSet.new) do
    print(state)
    IO.puts ""
    if old_states |> MapSet.member?(state) do
      state
    else
      find_duplicate_state(step(state), old_states |> MapSet.put(state))
    end
  end
end

defmodule Day24p2 do
  def parse(input) do
    input
    |> String.split("\n")
    |> Stream.filter(&(&1 != ""))
    |> Stream.with_index
    |> Stream.flat_map(fn {line, y} ->
      line
      |> String.to_charlist
      |> Stream.with_index
      |> Stream.flat_map(fn {c, x} ->
        case c do
          ?# ->
            [{0, x, y}]
          _ ->
            []
        end
      end)
    end)
    |> MapSet.new
  end

  def candidates(state) do
    state
    |> Stream.flat_map(fn p ->
      neighbors(p)
    end)
    |> MapSet.new()
  end

  def neighbors({level, x, y}) do
    Day18.neighbors({x, y})
    |> Stream.flat_map(fn {nx, ny} ->
      cond do
        {nx, ny} == {2, 2} ->
          case {x, y} do
            {2, _} ->
              newY = if y == 1, do: 0, else: 4
              0..4
              |> Stream.map(fn newX -> {level - 1, newX, newY} end)
            {_, 2} ->
              newX = if x == 1, do: 0, else: 4
              0..4
              |> Stream.map(fn newY -> {level - 1, newX, newY} end)
          end
        nx == -1 ->
          [{level + 1, 1, 2}]
        nx == 5 ->
          [{level + 1, 3, 2}]
        ny == -1 ->
          [{level + 1, 2, 1}]
        ny == 5 ->
          [{level + 1, 2, 3}]
        true ->
          [{level, nx, ny}]
      end
    end)
  end

  def step(state) do
    candidates(state)
    |> Stream.filter(fn p ->
      n = neighbors(p)
          |> Stream.filter(&(MapSet.member?(state, &1)))
          |> Enum.count
      if MapSet.member?(state, p) do
        n == 1
      else
        n == 1 || n == 2
      end
    end)
    |> MapSet.new
  end
end

