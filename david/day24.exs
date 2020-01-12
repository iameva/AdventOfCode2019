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
