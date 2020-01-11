defmodule Graph do
  def dijkstras({0, nil}, _, _, _), do: nil
  def dijkstras(set, visited, success, neighbors) do
    {{cost, state}, rest} = :gb_sets.take_smallest(set)
    IO.write "\r#{cost}"
    if success.(state) do
      IO.write "\n"
      {cost, state}
    else
      nbrs =
        neighbors.(state)
        |> Stream.map(fn {n, c} -> {n, cost + c} end )
        |> Stream.filter(fn {n, c} ->
          case visited[n] do
            nil ->
              true
            old_cost ->
              old_cost > c
          end
        end)
      new_visited =
        nbrs
        |> Enum.reduce(visited, fn {n, c}, v ->
          v |> Map.put(n, c)
        end)
      new_queue =
        nbrs
        |> Enum.reduce(rest, fn {n, c}, q ->
          :gb_sets.add({c, n}, q)
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
    doors =
      map
      |> Stream.flat_map(fn {p, c} ->
        if is_door(c) do
          <<key>> = String.downcase(<<c>>)
          [{key, p}]
        else
          []
        end
      end)
      |> Map.new
    {start_pos, _} = map |> Enum.find( fn {_, char} -> char == ?@ end)
    %{
      map: map,
      pos: start_pos,
      doors: doors
    }
  end

  def is_interesting(state, p) do
    case state.map[p] do
      ?# ->
        false
      ?. ->
        false
      _ ->
        true
    end
  end

  def find_neighbors(state, p) do
    starting_positions = neighbors(state, p)
    find_neighbors(state, starting_positions, [p] |> MapSet.new(), MapSet.new(), 1)
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
          |> Stream.flat_map(fn x -> neighbors(state, x) end)
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
    |> Stream.map(fn p -> {p, find_neighbors(state, p)} end)
    |> Map.new()
  end

  def verify(graph) do
    graph
    |> Map.keys
    |> Enum.each(fn k ->
      graph[k]
      |> Enum.each(fn {x, cost} ->
        nbrs = graph[x]
        if nbrs |> Enum.find(fn {n, c} -> n == k && c == cost end) == nil do
          IO.puts("#{inspect k} points to #{inspect x} but not the other way around")
        end
      end)
    end)
  end

  def merge_vertex(graph, v) do
    #IO.puts "#{inspect v} #{inspect graph[v]}"
    nbrs = graph[v]
    graph = graph |> Map.delete(v)
    result =
      nbrs
      |> Enum.reduce(graph, fn {nbr, cost}, graph ->
#      IO.puts "#{inspect nbr} #{inspect graph[nbr]}"
        ext_nbrs =
          graph[nbr]
          |> Map.new
        new_nbrs =
          nbrs
          |> Stream.map(fn {n, c} -> {n, c + cost} end)
          |> Map.new
        fnl_nbrs =
          new_nbrs
          |> Map.keys
          |> MapSet.new
          |> MapSet.union(ext_nbrs |> Map.keys |> MapSet.new)
          |> Stream.filter(fn n -> n != v && n != nbr end)
          |> Stream.map(fn n ->
            new_cost =
              case {Map.get(new_nbrs, n), Map.get(ext_nbrs, n)} do
                {nil, y} -> y
                {x, nil} -> x
                {x, y} when x < y -> x
                {_, y} -> y
              end
              {n, new_cost}
          end)
          |> Enum.to_list
          graph |> Map.put(nbr, fnl_nbrs)
      end)
    #verify(result)
    result
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
