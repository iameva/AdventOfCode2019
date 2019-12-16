map = Day10.parse_map(File.read!("data/day10"))
IO.puts inspect(Day10.find_most_visible(map))
