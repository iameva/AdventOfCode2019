defmodule Graph do
  def dijkstras([], _, _, _), do: nil
  def dijkstras([{cost, state} | rest], visited, success, neighbors) do
    IO.write "\r#{cost}"
    if success.(state) do
      {cost, state}
    else
      nbrs =
        neighbors.(state)
        |> Stream.filter(fn {c, n} ->
          c = cost + c
          case visited[n] do
            nil ->
              true
            old_cost ->
              old_cost > c
          end
        end)
        new_visited =
          nbrs
          |> Enum.reduce(visited, fn {c, n}, v ->
            v |> Map.put(n, cost + c)
          end)
        new_queue =
          nbrs
          |> Enum.reduce(rest, fn {c, n}, q ->
            :ordsets.add_element({cost + c, n}, q)
          end)
        dijkstras(new_queue, new_visited, success, neighbors)
    end
  end
end

defmodule Day18 do
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
          |> Map.new()
    nbrs =
      map
      |> Stream.flat_map(fn {p, c} ->
        case c do
          ?# ->
            []
          _ ->
            [{p, neighbors(%{map: map}, p)}]
        end
      end)
      |> Map.new
    {start_pos, _} = map |> Enum.find( fn {_, char} -> char == ?@ end)
    %{
      map: map,
      pos: start_pos,
      steps: 0,
      num_keys: 0,
      keys: MapSet.new(),
      neighbors: nbrs,
    }
  end

  def is_interesting(state, p) do
    case state.map[p] do
      ?@ ->
        true
      ?# ->
        false
      ?. ->
        # if this is an empty tile then it is only interesting if it has 3 open neighbors
        state.neighbors[p] |> Enum.count >= 3
      _ ->
        true
    end
  end

  def find_neighbors(state, p) do
    starting_positions = state.neighbors[p]
    find_neighbors(state, starting_positions, MapSet.new(), MapSet.new(), 1)
  end

  def find_neighbors(state, positions, visited, results, steps) do
    #IO.inspect {positions, visited, results}
    case positions do
      [] -> results |> Enum.to_list
      positions ->
        new_visited = 
          positions
          |> MapSet.new
          |> MapSet.union(visited)
        new_results =
          positions
          |> Stream.filter(&(is_interesting(state, &1)))
          |> Stream.map(&({&1, steps}))
          |> MapSet.new
          |> MapSet.union(results)
        new_positions =
          positions
          |> Stream.filter(&(!is_interesting(state, &1)))
          |> Stream.flat_map(fn x -> state.neighbors[x] end)
          |> Stream.filter(fn x ->
            !MapSet.member?(new_visited, x)
          end)
          |> Enum.uniq
        find_neighbors(state, new_positions, new_visited, new_results, steps + 1)
    end
  end

  def make_graph(state) do
    # find interesting points
    interesting_points = state.map
                         |> Map.keys()
                         |> Stream.filter(&(is_interesting(state, &1)))
                         |> Enum.to_list
    # each interesting point is a node in our graph
    interesting_points
    |> Stream.map(fn p -> {p, {Map.get(state.map, p), find_neighbors(state, p)}} end)
    |> Map.new()
  end

  def is_key(c) do
    c >= ?a && c <= ?z
  end

  def is_door(c) do
    c >= ?A && c <= ?Z
  end

  def neighbors({x, y}) do
    [{x, y + 1}, {x, y - 1}, {x + 1, y}, {x - 1, y}]
  end

  def neighbors(state, p) do
    neighbors(p)
    |> Enum.filter(fn p ->
      (state.map |> Map.get(p, ?#)) != ?#
    end)
  end
end
