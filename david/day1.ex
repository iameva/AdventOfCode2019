lines = File.stream!("data/day1")

total = lines |> Stream.map(&String.trim/1) |> Stream.filter(&("" != &1)) |> Stream.map(&String.to_integer/1) |> Stream.map(&Day1.requiredFuel/1) |> Enum.sum
IO.puts total
