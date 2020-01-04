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
          nil -> " "
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
      10 -> to_map(tail, {0, y + 1}, map)
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


  def opcodes do %{ Day11.opcodes |
    3 => fn (state) ->
      case state.input do
        [head | rest] ->
          state
          |> Day11.update(state |> Day11.at(state.pos + 1), head)
          |> Map.put(:input, rest)
          |> Day11.step_pos(2)
        [] ->
          state
          |> Map.put(:state, :need_input)
      end
    end,
    4 => fn (state) ->
      output = state |> Day11.get_parameter(1)
      state |> Map.put(:output, state.output ++ [output])
      |> Day11.step_pos(2)
    end,
    99 => fn (state) ->
      state
      |> Map.put(:state, :halted)
    end}
  end

  def process(state) do
    case state.state do
      :unstarted ->
        process(state |> Map.put(:state, :running))
      :need_input ->
        state
      :halted ->
        state
      :running ->
        baseOp = state |> Day11.current()
        op = baseOp |> rem(100)
        case opcodes()[op] do
          nil ->
            state |> Map.put(:state, :bad_op)
          code ->
            process(code.(state))
        end
    end
  end

  def slow_input(state, []), do: state
  def slow_input(state, [head| rest]) do
    IO.puts("sending #{inspect <<head>>}")
    next = process(state |> Map.put(:input, state.input ++ [head]) |> Map.put(:state, :running))
    case next.state do
      :need_input ->
        slow_input(next, rest)
      other ->
        IO.puts "state in #{other}, stopping"
        next
    end
  end

  def send_input(state, input) do
    process(state |> Map.put(:input, state.input ++ input) |> Map.put(:state, :running))
  end
end
