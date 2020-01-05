code = Day17.parse_state(File.read!("data/day17"))

program = Day17.process(code, Day17.opcodes(false))

IO.puts "program state #{program.state}"

IO.puts to_string(program.output)

state = Day17.to_map(program.output)

#state = Day17.read_state()

intersections = state
                |> Map.keys()
                |> Enum.filter(fn {x, y} ->
                  (state |> Map.get({x, y}) == ?#) &&
                  Day17.neighbors({x, y})
                  |> Stream.filter(fn p -> state |> Map.get(p) == ?# end)
                  |> Enum.count() >= 3
                end)
IO.puts "intersections: #{inspect intersections}"
newS = intersections
       |> Enum.reduce(state, fn i, s -> s |> Map.put(i, "O") end)
Day17.print_map(newS)
result = intersections
         |> Enum.reduce(0, fn {x, y}, sum ->
           sum + (x * y)
         end)

IO.puts "sum of allignment parameters: #{result}"
