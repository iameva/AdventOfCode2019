state = Day24.parse(File.read!("data/day24"))
Day24.find_duplicate_state(state)
|> IO.inspect
