moons = Day12.parse_moons(File.read!("data/day12"))
steps = Stream.iterate(moons, &Day12.step/1) |> Stream.with_index()

# find X period
find_period = fn (idx) ->
  to_idx_state = fn (moons) ->
    moons |> Enum.map(fn {_, moon} ->
      { Tuple.to_list(moon.pos) |> Enum.at(idx),
        Tuple.to_list(moon.vel) |> Enum.at(idx) }
    end)
  end
  starting_state = to_idx_state.(moons)
  {_, idx} =  steps |> Stream.drop(1) |> Enum.find(fn {step, _} ->
      to_idx_state.(step) == starting_state
    end)
  idx
end

x_period = find_period.(0)
y_period = find_period.(1)
z_period = find_period.(2)


IO.puts "x: #{x_period} y: #{y_period} z: #{z_period}"

lcm = x_period |> Day12.lcm(y_period) |> Day12.lcm(z_period)

IO.puts "lcm: #{lcm}"
