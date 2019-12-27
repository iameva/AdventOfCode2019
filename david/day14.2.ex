reactions = Day14.parse_reactions(File.read!("data/day14"))

fuel = Day14.count_fuel_from_ore(reactions, 1000000000000)
IO.puts("1000000000000 ore makes #{fuel} fuel")

