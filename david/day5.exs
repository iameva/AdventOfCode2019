defmodule MachineState do

  @enforce_keys [:pos, :mem]
  defstruct [:pos, :mem]

  def at(state, idx) do
    state.mem[idx]
  end

  def update(state, pos, value) do
    %{state| mem: %{state.mem | pos => value}}
  end

  def current(state) do
    state.mem[state.pos]
  end

  def get_parameter(state, parameter_num) do
    digit = case parameter_num do
        1 -> 100
        2 -> 1000
        3 -> 10000
      end
    mode = state.mem[state.pos] |> div(digit) |> rem(10)
    case mode do
      0 ->
        state |> at(state |> at(state.pos + parameter_num))
      1 ->
        state |> at(state.pos + parameter_num)
    end
  end

  def set_pos(state, pos) do
    %{state| pos: pos}
  end

  def step_pos(state, delta) do
    %{state| pos: state.pos + delta}
  end
end

defmodule Day5 do

  import MachineState

  def opcodes do %{
      1 => fn (state) ->
          result = get_parameter(state, 1) + get_parameter(state, 2)
          state
          |> update(state |> at(state.pos + 3), result)
          |> step_pos(4)          
        end,
      2 => fn (state) ->
          result = get_parameter(state, 1) * get_parameter(state, 2)
          state
          |> update(state |> at(state.pos + 3), result)
          |> step_pos(4)
        end,
      3 => fn (state) ->
          result =
            IO.gets("Input? ")
            |> String.trim()
            |> String.to_integer
          state
          |> update(state |> at(state.pos + 1), result)
          |> step_pos(2)
        end,
      4 =>  fn (state) ->
          IO.puts get_parameter(state, 1)
          state |> step_pos(2)
        end,
      5 => fn (state) ->
          if get_parameter(state, 1) != 0 do
            state |> set_pos(state |> get_parameter(2))
          else
            state |> step_pos(3)
          end
        end,
      6 => fn (state) ->
          if get_parameter(state, 1) == 0 do
            state |> set_pos(state |> get_parameter(2))
          else
            state |> step_pos(3)
          end
        end,
      7 => fn(state) ->
          result = if get_parameter(state, 1) < get_parameter(state, 2) do
              1
            else
              0
            end
          state
          |> update(state |> at(state.pos + 3), result)
          |> step_pos(4)
        end,
      8 => fn(state) ->
          result = if get_parameter(state, 1) == get_parameter(state, 2) do
              1
            else
              0
            end
          state
          |> update(state |> at(state.pos + 3), result)
          |> step_pos(4)
        end
    }
  end

  def parse_state(input) do
    %MachineState{
      mem: Day2.parse_state(input),
      pos: 0
    }
  end
  def load_state(file) do
    parse_state(File.read!(file))
  end

  def process(state, ops) do
    baseOp = state |> current()
    op = baseOp |> rem(10)
    case ops[op] do
      nil -> state
      code ->
        process(code.(state), ops)
    end
  end

end
