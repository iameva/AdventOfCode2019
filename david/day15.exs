defmodule Day15 do
  def start_program(code) do
    pid = spawn_link fn () -> Day11.process(code, Day11.opcodes()) end
    send(pid, {:set_output, self()})
    pid
  end

  # 1, 2, 3, 4 = north, south, east, west
  # result: 
  #   0: hit wall
  #   1: moved successfully
  #   2: moved and found oxygen system (the goal)
  def move(pid, dir) do
#    IO.puts("sending #{inspect (dir |> dir_to_vec())} as #{msg}")
    send(pid, {:input, dir})
    receive do
      {:input, result} ->
#        IO.puts "received #{result}"
        result
    end
  end

  def dir_to_vec(dir) do
    case dir do
      1 -> {0, 1}
      2 -> {0, -1}
      3 -> {1, 0}
      4 -> {-1, 0}
    end
  end
  def turn_right(dir) do
    case dir do
      1 -> 3
      2 -> 4
      3 -> 2
      4 -> 1
    end
  end
  def turn_left(dir) do
    turn_right(turn_right(turn_right(dir)))
  end

  def print_state(state) do
    map = state.map
    minX = (map |> Map.keys() |> Stream.map(fn {x, _} -> x end) |> Enum.min()) - 1
    minY = (map |> Map.keys() |> Stream.map(fn {_, y} -> y end) |> Enum.min()) - 1
    maxX = (map |> Map.keys() |> Stream.map(fn {x, _} -> x end) |> Enum.max()) + 1
    maxY = (map |> Map.keys() |> Stream.map(fn {_, y} -> y end) |> Enum.max()) + 1
    IO.puts maxY..minY
    |> Stream.flat_map(fn y ->
      minX..maxX
      |> Stream.map(fn x -> {x, y} end)
    end)
    |> Enum.reduce("\n", fn {x, y}, str ->
      char = if state.pos == {x, y} do
        case state.dir do
          1 -> "^"
          2 -> "v"
          3 -> ">"
          4 -> "<"
        end
      else
        case state.map |> Map.get({x, y}) do
          0 -> "#"
          1 -> " "
          2 -> "X"
          nil -> " "
          x -> x
        end
      end
        if x == minX do
          str <> "\n" <> char
        else
          str <> char
        end
    end)
  end

  defp internal_explore(state, pid) do
    old_start = state |> Map.get(:start)
    if {state.pos, state.dir} == old_start do
      state
    else
      state = if old_start == nil do
        state |> Map.put(:start, {state.pos, state.dir})
      else
        state
      end
      left_dir = state.dir |> turn_left()
      left_pos = Vec.add(state.pos, left_dir |> dir_to_vec())
      forward_pos = Vec.add(state.pos, state.dir |> dir_to_vec())
      case (state.map |> Map.get(left_pos)) do
        nil ->
          #try moving here
          case move(pid, left_dir) do
            0 ->
              new_state = %{state | map: (state.map |> Map.put(left_pos, 0))}
              internal_explore(new_state, pid)
            x ->
              new_state = %{state | map: (state.map |> Map.put(left_pos, x)), pos: left_pos, dir: left_dir}
              internal_explore(new_state, pid)
          end
        0 ->
          #wall, try going straight
          case move(pid, state.dir) do
            0 ->
              new_state = %{state | map: (state.map |> Map.put(forward_pos, 0)), dir: turn_right(state.dir)}
              internal_explore(new_state, pid)
            x ->
              new_state = %{state | map: (state.map |> Map.put(forward_pos, x)), pos: forward_pos}
              internal_explore(new_state, pid)
          end
        x ->
          #open, turn and go here
          case move(pid, left_dir) do
            x when x != 0 -> () #this is expected
          end
          new_state = %{state | pos: left_pos, dir: left_dir}
          internal_explore(new_state, pid)
      end
    end
  end

  defp move_to_edge(state, pid) do
#    print_state(state)
    target_pos = Vec.add(state.pos, dir_to_vec(state.dir))
    case move(pid, state.dir) do
      0 ->
        %{state | map: (state.map |> Map.put(target_pos, 0)), dir: turn_right(state.dir)}
      x ->
        new_state = %{state | map: (state.map |> Map.put(target_pos, x)), pos: target_pos}
        move_to_edge(new_state, pid)
    end
  end

  def explore_map(pid) do
    map = %{{0, 0} => 1}
    state = %{map: map, pos: {0, 0}, dir: 1, start: {{0, 0}, 1}}
    state = move_to_edge(state, pid)
    internal_explore(state, pid)
  end

  defp shortest_path(state, neighbors, paths, [next | rest]) do
    case state.map |> Map.get(hd(next)) do
      2 ->
        next
      1 ->
        paths = paths |> Map.put(hd(next), next)
        steps = next |> Enum.count()
        next_to_consider = neighbors.(hd(next)) |> Stream.filter(fn n ->
          (paths |> Map.get(n)) == nil
        end)
        |> Stream.map(fn n -> [n | next] end)
        shortest_path(state, neighbors, paths, Enum.concat([rest, next_to_consider]))
    end
  end

  def find_shortest_path(state) do
    shortest_path(
      state,
      fn {x, y} ->
        [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
        |> Enum.filter(fn p ->
          tile = state.map |> Map.get(p)
          tile == 1 || tile == 2
        end)
      end,
      %{},
      [[{0, 0}]]
    )
  end

  def part_two(state, recently_oxidized, steps \\ 0) do
    :timer.sleep(10)
    next_oxidized = recently_oxidized
                    |> Stream.flat_map(fn {x, y} ->
                      [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
                      |> Enum.filter(fn p ->
                        tile = state.map |> Map.get(p)
                        tile != 0 && tile != "O"
                      end)
                    end)
    if next_oxidized |> Enum.empty?() do
      steps
    else
      new_map = next_oxidized
                |> Enum.reduce(state.map, fn x, m -> m |> Map.put(x, "O") end)
      new_state = %{state | map: new_map}
      print_state(new_state)
      part_two(new_state, next_oxidized, steps + 1)
    end
  end
end
