initial_state = Day2.load_state("data/day2")
for noun <- 0..99,
    verb <- 0..99,
    state = %{initial_state | 1 => noun, 2 => verb},
    final_state = Day2.process(state, 0),
    result = 100 * noun + verb,
    final_state[0] == 19690720 do
  IO.puts "noun: #{noun} verb: #{verb} mult: #{result}"
end

