initial_state = Day18.parse(File.read!("data/day18"))

{x, y} = initial_state.pos
starting_positions = [{x - 1, y - 1}, {x - 1, y + 1}, {x + 1, y - 1}, {x + 1, y + 1}]
new_map = 
  starting_positions
  |> Enum.reduce(initial_state.map, fn p, m -> m |> Map.put(p, ?@) end)
  |> Map.put({x, y}, ?#)
  |> Map.put({x - 1, y}, ?#)
  |> Map.put({x + 1, y}, ?#)
  |> Map.put({x, y - 1}, ?#)
  |> Map.put({x, y + 1}, ?#)

state = initial_state |> Map.put(:map, new_map)
Day17.print_map(state.map)

graph = Day18.make_graph(state)

num_keys =
  state.map
  |> Stream.filter(fn {_, c} -> Day18.is_key(c) end)
  |> Enum.count

result = Graph.dijkstras(
  :gb_sets.from_list([{0, {starting_positions, MapSet.new, graph}}]),
  Map.new,
  fn {_, keys, _} ->
    (keys |> Enum.count) == num_keys
  end,
  fn {positions, keys, graph} ->
    positions
    |> Stream.with_index
    |> Stream.flat_map(fn {old_pos, idx} ->
      neighbors = graph[old_pos]
      graph = Day18.merge_vertex(graph, old_pos)
      neighbors
      |> Stream.flat_map(fn {pos, cost} ->
        char = state.map[pos]
        new_positions = positions |> List.replace_at(idx, pos)
        if Day18.is_key(char) do
          door = state.doors[char]
          graph = Day18.merge_vertex(graph, door)
          [{{new_positions, keys |> MapSet.put(char), graph}, cost}]
        else
          []
        end
      end)
    end)
  end)

IO.inspect result
