input = """
OR A T
AND B T
AND C T
NOT T T
AND D T
OR T J
WALK
"""

code = Day17.parse_state(File.read!("data/day21"))
       |> Map.put(:input, String.to_charlist(input))

end_state = Day17.process(code, Day17.opcodes(false))

end_state.output |> Enum.reduce(nil, fn x, _ -> x end) |> IO.inspect
