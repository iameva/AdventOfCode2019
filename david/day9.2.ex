state = Day9.parse_state(File.read!("data/day9")) |> Day9.set_input([2])
result = Day9.process(state, Day9.opcodes())
result.output |> Enum.reverse() |> Enum.each(&IO.puts/1)
