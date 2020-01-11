state = Day20.parse(File.read!("data/day20"))

graph = Day20.make_graph(state)

{start, _} = state.portals |> Enum.find(fn {_, p} -> p == "AA" end)
{goal, _} = state.portals |> Enum.find(fn {_, p} -> p == "ZZ" end)
IO.puts "start #{inspect start} goal #{inspect goal}"

Graph.dijkstras(
  start,
  &(&1 == goal),
  &(graph[&1]))
  |> IO.inspect
