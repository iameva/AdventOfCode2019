defmodule Day20 do
  def parse(input) do
    map = input
          |> String.split("\n")
          |> Stream.filter(fn x -> x != "" end)
          |> Stream.with_index
          |> Stream.flat_map(fn {line, y} ->
            line
            |> to_charlist
            |> Stream.with_index
            |> Stream.map(fn {char, x} ->
              {{x, y}, char}
            end)
          end)
          |> Map.new
    portals =
      map
      |> Stream.filter(fn {_, c} -> c == ?. end)
      |> Stream.map(fn {p, _} -> {p, get_portal(map, p)} end)
      |> Stream.filter(fn {_, p} -> p != nil end)
      |> Map.new
    %{map: map, portals: portals}
  end

  def neighbors(state, p) do
    Day18.neighbors(p)
    |> Stream.filter(fn n -> state.map[n] == ?. end)
    |> Enum.to_list
  end

  def find_portal_neighbors(state, p) do
    starting_positions = neighbors(state, p)
    find_portal_neighbors(state, starting_positions, [p] |> MapSet.new(), %{}, 1)
  end

  def find_portal_neighbors(state, positions, visited, results, steps) do
    #IO.inspect {positions, visited, results}
    case positions do
      [] ->
        results
      positions ->
        new_visited = 
          positions
          |> MapSet.new
          |> MapSet.union(visited)
        new_results =
          positions
          |> Stream.filter(&(state.portals[&1] != nil))
          |> Stream.map(&({&1, steps}))
          |> Map.new
          |> Map.merge(results)
        new_positions =
          positions
          |> Stream.flat_map(fn x -> neighbors(state, x) end)
          |> Stream.filter(fn x ->
            !MapSet.member?(new_visited, x)
          end)
          |> Enum.uniq
        find_portal_neighbors(state, new_positions, new_visited, new_results, steps + 1)
    end
  end

  def make_graph(state) do
    # each interesting point is a node in our graph
    graph = state.portals
    |> Stream.map(fn {p, _} -> {p, find_portal_neighbors(state, p)} end)
    |> Map.new()
    # now link up the portals
    state.portals
    |> Stream.map(fn {_, p} -> p end)
    |> MapSet.new
    |> Enum.reduce(graph, fn portal, graph ->
      case state.portals |> Enum.filter(fn {_, p} -> p == portal end) do
        [{x, _}, {y, _}] ->
          oldX = graph[x]
          oldY = graph[y]
          graph
          |> Map.put(x, oldX |> Map.put(y, 1))
          |> Map.put(y, oldY |> Map.put(x, 1))
        _ ->
          graph
      end
    end)
  end

  def is_letter(x), do: x >= ?A && x <= ?Z

  def get_portal(map, p) do
    letter_pos = Day18.neighbors(p) |> Enum.find(fn n -> is_letter(map[n]) end)
    if letter_pos != nil do
      letter = map[letter_pos]
      {x, y} = letter_pos
      cond do
        is_letter(map[{x - 1, y}]) ->
          <<map[{x - 1, y}], letter>>
        is_letter(map[{x + 1, y}]) ->
          <<letter, map[{x + 1, y}]>>
        is_letter(map[{x, y - 1}]) ->
          <<map[{x, y - 1}], letter>>
        is_letter(map[{x, y + 1}]) ->
          <<letter, map[{x, y + 1}]>>
      end
    else
      nil
    end
  end
end
