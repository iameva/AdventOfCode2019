[wire1, wire2] = Day3.parse_wires(File.read!("data/day3"))

IO.puts Day3.find_steps_to_soonest_intersection(wire1, wire2)

