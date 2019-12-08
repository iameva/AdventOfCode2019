defmodule Day7 do
  def permutations([]), do: [[]]
  def permutations(list), do: for elem <- list, rest <- permutations(list--[elem]), do: [elem|rest]
  
  def parse_state(str) do
    Day5.parse_state(str)
    |> Map.put(:input, [])
    |> Map.put(:output, [])
  end

  def with_input(state, new_input) do
    %{state| input: new_input}
  end

  def with_output(state, out) do
    %{state| output: [out | state.output]}
  end

  import MachineState

  def opcodes do
    %{Day5.opcodes |
      3 => fn (state) ->
          [head|tail] = state.input
          state
          |> update(state |> at(state.pos + 1), head)
          |> step_pos(2)
          |> with_input(tail)
        end,
      4 => fn (state) ->
          state
          |> with_output(state |> get_parameter(1))
          |> step_pos(2)
        end
    }
  end

  def run_permutation(perm, program) do
    Enum.reduce(
      perm,
      0,
      fn (idx, input) ->
        result_state = Day5.process(program |> with_input([idx, input]), opcodes())
        hd(result_state.output)
      end
    )
  end

  def find_best_permutation(program) do
    permutations([0, 1, 2, 3, 4])
    |> Stream.map(&(run_permutation(&1, program)))
    |> Enum.max()
  end

  def process_opcodes do
    %{opcodes() |
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
        end
    } |> Map.put(
      99, fn (state) ->
          receive do
            {:input, msg} ->
              send(state.on_hault, {:result, msg})
              state
            {:kill} -> state |> update(state.pos, 0) #unknown opcode terminates 
          end
        end
      )
  end

  def process(program, ops) do
    Day5.process(program, ops)
  end

  def part_two(program) do
    run_perm = fn(perm) ->
      #spawn amplifiers
      amplifiers =
        perm
        |> Enum.map(fn (input) ->
            p = program |> Map.put(:on_hault, self())
            pid = spawn_link fn -> Day7.process(p, process_opcodes()) end
            send(pid, {:input, input})
            pid
          end
        )
      #point them at eachother
      first = hd(amplifiers)
      amplifiers
      |> Enum.chunk_every(2, 1, [first])
      |> Enum.each(fn [a, b] -> send(a, {:set_output, b}) end)
      # start the first one
      send(hd(amplifiers), {:input, 0})
      result = receive do
        {:result, r} -> r
      end
      amplifiers
      |> Enum.each(&(send(&1, {:kill})))
      result
    end
    permutations([5, 6, 7, 8, 9])
    |> Stream.map(&(run_perm.(&1)))
    |> Enum.max()
  end

end
