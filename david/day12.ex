moons = Day12.parse_moons(File.read!("data/day12"))
steps = Stream.iterate(moons, &Day12.step/1)
finalState = steps |> Enum.at(1000)

IO.puts "system energy: #{Day12.energy(finalState)}"
