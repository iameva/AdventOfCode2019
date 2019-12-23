reactions = Day14.parse_reactions(File.read!("data/day14"))

IO.puts "1 fuel = #{inspect Day14.make_chemical(reactions, %{}, "FUEL", 1)} ore"

