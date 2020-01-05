code = Day17.parse_state(File.read!("data/day17"))

map = Day17.to_map(Day17.process(code, Day17.opcodes(false)).output)

Day17.print_map(map)

{pos, dir} = map |> Enum.find(fn {_, x} -> x == ?> || x == ?< || x == ?^ || x == ?v end)
dir = case dir do
  ?> -> 3
  ?< -> 4
  ?v -> 2
  ?^ -> 1
end

path = Day17.create_path(map, pos, dir, [], 0) |> Enum.filter(fn x -> x != 0 end)

IO.puts Enum.join(path, ",")

main = """
A,B,A,C,B,C,B,C,A,C
L,10,R,12,R,12
R,6,R,10,L,10
R,10,L,10,L,12,R,6
n
"""

end_state = code |> Day11.update(0, 2) |> Map.put(:input, to_charlist(main)) |> Day17.process(Day17.opcodes())

end_state.output |> Enum.reduce(nil, fn x, _ -> x end) |> IO.inspect

