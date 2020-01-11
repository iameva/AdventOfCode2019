code = Day17.parse_state(File.read!("data/day19"))

map = 0..49
|> Stream.flat_map(fn x ->
  0..49
  |> Stream.map(fn y ->
    [result] = (code |> Day19.run([x, y]))
    char = if result == 0 do
      ?.
    else
      ?#
    end
    {{x, y}, char}
  end)
end)
|> Map.new

Day17.print_map(map)

map
|> Stream.filter(fn {_, c} -> c == ?# end)
|> Enum.count
|> IO.inspect
