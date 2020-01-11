state = Day20.parse(File.read!("data/day20"))

graph = Day20.make_graph(state)

{minX, maxX} = graph |> Map.keys |> Stream.map(fn {x, _} -> x end) |> Enum.min_max
{minY, maxY} = graph |> Map.keys |> Stream.map(fn {_, y} -> y end) |> Enum.min_max

is_outer = fn {x, y} -> x == minX || x == maxX || y == minY || y == maxY end

{start, _} = state.portals |> Enum.find(fn {_, p} -> p == "AA" end)
{goal, _} = state.portals |> Enum.find(fn {_, p} -> p == "ZZ" end)
IO.puts "start #{inspect start} goal #{inspect goal}"

Graph.dijkstras(
  {start, 0},
  &(&1 == {goal, 0}),
  fn {p, level} ->
    IO.write " #{Kernel.inspect({p, level})}"
    nbrs = graph[p]
    outer? = is_outer.(p)
    portal = state.portals[p]
    nbrs
    |> Stream.map(fn {nbr, c} ->
      if state.portals[nbr] == portal do
        if outer? do
          {{nbr, level - 1}, c}
        else
          {{nbr, level + 1}, c}
        end
      else
        {{nbr, level}, c}
      end
    end)
    |> Stream.filter(fn {{_, level}, _} -> level >= 0 end)
    |> Map.new
  end)
  |> IO.inspect
