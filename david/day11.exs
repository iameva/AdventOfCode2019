defmodule Day11 do

  def update(state, pos, value) do
    %{state| mem: state.mem |> Map.put(pos, value)}
  end

  def current(state) do
    state.mem[state.pos]
  end

  def set_pos(state, pos) do
    %{state| pos: pos}
  end

  def step_pos(state, delta) do
    %{state| pos: state.pos + delta}
  end

  def at(state, idx) do
    state.mem |> Map.get(idx, 0)
  end

  def set_input(state, new_input) do
    %{state| input: new_input}
  end

  def with_output(state, out) do
    %{state| output: state.output ++ [out]}
  end

  def step_offset(state, delta) do
    %{state| offset: state.offset + delta}
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
      2 ->
        state |> at(state.offset + (state |> at(state.pos + parameter_num)))
    end
  end

  def out_parameter(state, parameter_num) do
    digit = case parameter_num do
        1 -> 100
        2 -> 1000
        3 -> 10000
      end
    mode = state.mem[state.pos] |> div(digit) |> rem(10)
    case mode do
      0 ->
        state |> at(state.pos + parameter_num)
      2 ->
        state.offset + (state |> at(state.pos + parameter_num))
    end
  end

  def parse_state(str) do
    mem = String.split(str, ",")
      |> Stream.map(&String.trim/1)
      |> Stream.filter(&(&1 != ""))
      |> Stream.map(&String.to_integer/1)
      |> Stream.with_index
      |> Stream.map(fn({a, b}) -> {b, a} end)
      |> Map.new
    %{
      :mem => mem,
      :pos => 0,
      :input => [],
      :output => [],
      :offset => 0,
      :haulted => false
    }
  end

  def opcodes do
    %{
      1 => fn (state) ->
          result = get_parameter(state, 1) + get_parameter(state, 2)
          state
          |> update(state |> out_parameter(3), result)
          |> step_pos(4)
        end,
      2 => fn (state) ->
          result = get_parameter(state, 1) * get_parameter(state, 2)
          state
          |> update(state |> out_parameter(3), result)
          |> step_pos(4)
        end,
      3 => fn (state) ->
          receive do
            {:input, msg} ->
              state
              |> update(state |> at(state.pos + 1), msg)
              |> step_pos(2)
            {:set_output, pid} ->
              state
              |> Map.put(:outpid, pid)
          end
        end,
      4 => fn (state) ->
          case state.outpid do
            nil ->
              receive do
                {:set_output, pid} ->
                  send(pid, {:input, state |> get_parameter(1)})
                  state
                  |> Map.put(:outpid, pid)
                  |> step_pos(2)
              end
            pid ->
              send(pid, {:input, state |> get_parameter(1)})
              state
              |> step_pos(2)
          end
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
          |> update(state |> out_parameter(3), result)
          |> step_pos(4)
        end,
      8 => fn(state) ->
          result = if get_parameter(state, 1) == get_parameter(state, 2) do
              1
            else
              0
            end
          state
          |> update(state |> out_parameter(3), result)
          |> step_pos(4)
        end,
      9 => fn(state) ->
          state
          |> step_offset(state |> get_parameter(1))
          |> step_pos(2)
        end,
      99 => fn (state) ->
          send(state.outpid, :halted)
          IO.puts "HALTED PROCESS"
          state |> Map.put(:haulted, true)
        end
    }
  end

  def process(state, ops) do
    baseOp = state |> current()
    op = baseOp |> rem(100)
    if(state.haulted, do: state, else: case ops[op] do
      nil -> state
      code ->
        process(code.(state), ops)
    end)
  end
  
  def add({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end
end
