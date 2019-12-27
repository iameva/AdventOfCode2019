defmodule Day16 do
  def parse_input(str) do
    String.codepoints(str)
    |> Stream.flat_map(fn x ->
      case x do
        "0" -> [0]
        "1" -> [1]
        "2" -> [2]
        "3" -> [3]
        "4" -> [4]
        "5" -> [5]
        "6" -> [6]
        "7" -> [7]
        "8" -> [8]
        "9" -> [9]
        _ -> []
      end
    end)
    |> Enum.to_list()
  end

  # 1 based index
  def pattern_for(idx) do
    [0, 1, 0, -1]
    |> Stream.flat_map(fn x ->
      Stream.repeatedly(fn () -> x end) |> Stream.take(idx)
    end)
    |> Stream.cycle()
    |> Stream.drop(1)
  end

  def take_digit(x) do
    Kernel.abs(rem(x, 10))
  end

  def fft(input) do
    IO.puts "fft (#{inspect input})"
    (1..Enum.count(input))
    |> Stream.map(&pattern_for/1)
    |> Stream.map(fn pattern ->
      Enum.zip(pattern, input)
      |> Stream.map(fn {a, b} -> a * b end)
      |> Enum.sum()
      |> take_digit()
    end)
    |> Enum.to_list()
  end

  def fft2(input, len) do
    IO.puts "fft2 (#{inspect input})"
    (1..len)
    |> Stream.map(fn idx ->
      [0, 1, 0, -1]
      |> Stream.cycle()
      |> Enum.reduce_while({0, [0 | input]}, fn x, {acc, rest} ->
        if Enum.empty?(rest) do
          {:halt, acc}
        else
          case x do
            0 -> {:cont, {acc, rest |> Enum.drop(idx)}}
            1 -> {:cont, {acc + (rest |> Stream.take(idx) |> Enum.sum()), rest |> Enum.drop(idx)}}
            -1 -> {:cont, {acc - (rest |> Stream.take(idx) |> Enum.sum()), rest |> Enum.drop(idx)}}
          end
        end
      end)
      |> take_digit()
    end)
    |> Enum.to_list()
  end
end
