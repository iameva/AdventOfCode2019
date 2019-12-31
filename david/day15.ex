code = Day11.parse_state(File.read!("data/day15"))
pid = Day15.start_program(code)

state = Day15.explore_map(pid)
Day15.print_state(state)

path = Day15.find_shortest_path(state)

IO.puts "len: #{(path |> Enum.count()) - 1}"
#path |> Enum.reverse() |> Enum.each(fn x -> IO.puts "#{inspect x}" end)
