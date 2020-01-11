code = Day17.parse_state(File.read!("data/day19"))

start = {3, 4}

{x, y} =
  Stream.iterate(
    start,
    fn {x, y} ->
      [{x, y + 1}, {x + 1, y + 1}] |> Enum.find(fn p -> Day19.check?(code, p) end)
    end)
    |> Enum.find(fn {x, y} -> Day19.check?(code, {x + 99, y - 99}) end)

IO.inspect {x, y - 99}
IO.inspect (x * 10000 + y - 99)
