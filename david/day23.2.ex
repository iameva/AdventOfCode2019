code = Day23.parse(File.read!("data/day23"))

0..49 |> Enum.each(fn id -> Day23.start(code, id) end)

IO.inspect Day23.route_packets_2(0..49 |> Enum.map(&({&1, [&1]})) |> Map.new |> Map.put(:idle, MapSet.new()))

