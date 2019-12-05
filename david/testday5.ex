initial_state = Day5.load_state("data/day2")
import MachineState
state = initial_state |> update(1, 12) |> update(2, 2)
final_state = Day5.process(state, Day5.opcodes)
IO.puts "#{final_state |> at(0)}"
