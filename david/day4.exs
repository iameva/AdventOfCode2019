defmodule Day4 do
  def might_be_password(number) do
    str = Integer.to_string(number)
    String.length(str) == 6 &&
      Enum.any?(Stream.chunk_every(String.to_charlist(str), 2, 1, :discard), fn [a, b] -> a == b end) &&
      Enum.all?(Stream.chunk_every(String.to_charlist(str), 2, 1, :discard), fn [a, b] -> b >= a end)
  end

  def maybe_pw_2(number) do 
    str = Integer.to_string(number)
    String.length(str) == 6 &&
      Enum.any?(Stream.chunk_every(String.to_charlist(str), 2, 1, :discard), fn [a, b] -> a == b end) &&
      Enum.all?(Stream.chunk_every(String.to_charlist(str), 2, 1, :discard), fn [a, b] -> b >= a end) &&
      String.to_charlist(str) |>
        Stream.chunk_while([0, 0], fn elem, [last, cnt] ->
          if elem == last do
            {:cont, [last, cnt + 1]}
          else
            {:cont, cnt, [elem, 1]}
          end end,
          fn [last, cnt] -> {:cont, cnt, [last, cnt]} end) |>
        Stream.filter(&(&1 > 1)) |>
        Enum.any?(&(&1 == 2))
  end
end
