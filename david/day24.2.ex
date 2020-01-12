state = Day24p2.parse(File.read!("data/day24"))

Stream.iterate(state, &Day24p2.step/1)
|> Enum.at(200)
|> Enum.count
|> IO.inspect
