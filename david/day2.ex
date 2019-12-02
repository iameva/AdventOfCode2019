initial_state = Day2.load_state("data/day2")
state = %{initial_state | 1 => 12, 2 => 2}
final_state = Day2.process(state, 0)
IO.puts final_state[0]
