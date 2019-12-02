file = File.read!("data/day1")
lines = String.split(file, "\n")

total = lines |> Stream.filter(&("" != &1)) |> Stream.map(&String.to_integer/1) |> Stream.map(&Day1.requiredFuel/1) |> Enum.sum
IO.puts total
