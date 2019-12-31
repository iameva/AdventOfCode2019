code = Day11.parse_state(File.read!("data/day15"))
pid = Day15.start_program(code)

state = Day15.explore_map(pid)
Day15.print_state(state)

{oxygen, _} = state.map
         |> Enum.find(fn {p, x} -> x == 2 end)

time = Day15.part_two(state, [oxygen])

IO.puts "time to oxidize #{time}"
