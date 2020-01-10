defmodule Day17 do
  def print_map(m) when m == %{} do
    IO.puts("")
  end

  def print_map(map) do
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
      char = case map |> Map.get({x, y}) do
          nil -> ? 
          x -> x
        end
      if x == minX do
        str <> "\n" <> List.to_string([char])
      else
        str <> List.to_string([char])
      end
    end)
  end

  def to_map(input, pt \\ {0, 0}, map \\ %{})
  def to_map([], _, map), do: map
  def to_map([char | tail], {x, y}, map) do
    case char do
      10 -> to_map(tail, {0, y - 1}, map)
      _ -> to_map(tail, {x + 1, y}, map |> Map.put({x, y}, char))
    end
  end

  def neighbors({x, y}) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
  end

  def parse_state(input) do
    Day11.parse_state(input)
    |> Map.put(:input, [])
    |> Map.put(:output, [])
    |> Map.put(:state, :unstarted)
  end


  def opcodes(useIO \\ false) do %{ Day11.opcodes |
    3 => fn (state) ->
      case state.input do
        [head | rest] ->
          state
          |> Day11.update(state |> Day11.out_parameter(1), head)
          |> Map.put(:input, rest)
          |> Day11.step_pos(2)
        [] ->
          if useIO do
            input = IO.gets(to_string(state.output))
            state
            |> Map.put(:input, to_charlist(input))
            |> Map.put(:output, [])
          else
            state
            |> Map.put(:state, :need_input)
          end
      end
    end,
    4 => fn (state) ->
      output = state |> Day11.get_parameter(1)
      if useIO do
        IO.write(<<output>>)
        state
        |> Day11.step_pos(2)
      else
        state
        |> Map.put(:output, state.output ++ [output])
        |> Day11.step_pos(2)
      end
    end,
    99 => fn (state) ->
      state
      |> Map.put(:state, :halted)
    end}
  end

  def process(state, opcodes) do
    case state.state do
      :unstarted ->
        process(state |> Map.put(:state, :running), opcodes)
      :need_input ->
        state
      :halted ->
        state
      :running ->
        baseOp = state |> Day11.current()
        op = baseOp |> rem(100)
        case opcodes[op] do
          nil ->
            state |> Map.put(:state, :bad_op)
          code ->
            process(code.(state), opcodes)
        end
    end
  end

  def slow_input(state, []), do: state
  def slow_input(state, [head| rest]) do
    IO.puts("sending #{inspect <<head>>}")
    next = process(state |> Map.put(:input, state.input ++ [head]) |> Map.put(:state, :running), opcodes())
    case next.state do
      :need_input ->
        slow_input(next, rest)
      other ->
        IO.puts "state in #{other}, stopping"
        IO.puts to_string(state.output)
        next
    end
  end

  def send_input(state, input) do
    process(state |> Map.put(:input, state.input ++ input) |> Map.put(:state, :running), opcodes())
  end


  def create_path(map, pos, dir, path, num) do
    next_pos = Vec.add(pos, Day15.dir_to_vec(dir))
    case map |> Map.get(next_pos, ?.) do
      ?. ->
        # we've reached the end of a path. we must turn
        left = Day15.turn_left(dir)
        left_pos = Vec.add(pos, Day15.dir_to_vec(left))
        case map |> Map.get(left_pos, ?.) do
          ?. ->
            #can't go left, lets try right
            right = Day15.turn_right(dir)
            right_pos = Vec.add(pos, Day15.dir_to_vec(right))
            case map |> Map.get(right_pos, ?.) do
              ?. ->
                # can't turn left, we must be done
                path ++ [num]
              _ ->
                # turn right
                create_path(map, right_pos, right, path ++ [num, :R], 1)
            end
          _ ->
            # turn left
            create_path(map, left_pos, left, path ++ [num, :L], 1)
        end
      _ ->
        # still on valid path, continue
      create_path(map, next_pos, dir, path, num + 1)
    end
  end
end
