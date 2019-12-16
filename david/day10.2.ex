point = {37, 25}
map = Day10.parse_map(File.read!("data/day10"))
directions = map
|> Stream.filter(&(&1 != point))
|> Stream.map(fn {x, y} -> Day10.simplified_vector(Day10.sub({x, y}, point)) end)
|> MapSet.new()
|> Enum.sort_by(fn {x, y} ->
    Day10.to_angle({x, -y})
  end)

pt = directions |> Enum.at(199)

finalPt = map
|> Enum.find(fn {x, y} ->
    {x, y} != point && Day10.simplified_vector(Day10.sub({x, y}, point)) == pt
  end)

{x, y} = finalPt

IO.puts x * 100 + y
