state = Day18.parse(File.read!("data/day18"))

nbrs = Day18.find_neighbors(state, state.pos)

graph = Day18.make_graph(state)

IO.inspect graph

IO.puts "nodes: #{graph |> Enum.count()}"

num_keys =
  state.map
  |> Stream.filter(fn {_, c} -> Day18.is_key(c) end)
  |> Enum.count

result = Graph.dijkstras(
  :gb_sets.from_list([{0, {state.pos, MapSet.new, graph}}]),
  Map.new,
  fn {pos, keys, graph} ->
    (keys |> Enum.count) == num_keys
  end,
  fn {pos, keys, graph} ->
    neighbors = graph[pos]
    graph = Day18.merge_vertex(graph, pos)
    neighbors
    |> Stream.flat_map(fn {pos, cost} ->
      char = state.map[pos]
      if Day18.is_key(char) do
        door = state.doors[char]
        graph = Day18.merge_vertex(graph, door)
        [{{pos, keys |> MapSet.put(char), graph}, cost}]
      else
        if Day18.is_door(char) do
          []
        else
          [{{pos, keys, graph}, cost}]
        end
      end
    end)
  end)

IO.inspect result
