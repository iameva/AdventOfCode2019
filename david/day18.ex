state = Day18.parse(File.read!("data/day18"))
IO.puts "start: #{inspect(state)}"

interesting = state.map
              |> Map.keys()
              |> Stream.filter(&(Day18.is_interesting(state, &1)))
              |> Enum.to_list
IO.puts "interesting #{inspect interesting}"
nbrs = Day18.find_neighbors(state, state.pos)

IO.puts "nbrs: #{inspect nbrs}"


graph = Day18.make_graph(state)

IO.inspect graph

IO.puts "nodes: #{graph |> Enum.count()}"
num_keys =
  state.map
  |> Stream.filter(fn {_, c} -> Day18.is_key(c) end)
  |> Enum.count
# state consists of:
# {pos, keys, num_steps}
result = Graph.dijkstras(
  [{0, {state.pos, MapSet.new}}],
  Map.new,
  fn {pos, keys} ->
    (keys |> Enum.count) == num_keys
  end,
  fn {pos, keys} ->
    {_,  neighbors} = graph[pos]
    neighbors
    |> Stream.flat_map(fn {pos, cost} ->
      char = state.map[pos]
      if Day18.is_key(char) do
        [{cost, {pos, keys |> MapSet.put(char)}}]
      else
        if Day18.is_door(char) do
          <<lower>> = String.downcase(<<char>>)
          if MapSet.member?(keys, lower) do
            [{cost, {pos, keys}}]
          else
            []
          end
        else
          [{cost, {pos, keys}}]
        end
      end
    end)
  end)

IO.inspect result
