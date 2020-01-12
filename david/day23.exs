defmodule Day23 do
  def parse(input) do
    Day17.parse_state(input)
  end

  def start(code, id) do
    code = code |> Map.put(:id, id) |> Map.put(:out, self())
    spawn_link fn -> Day11.process(code, opcodes()) end
  end

  def opcodes() do
    Day11.opcodes()
    |> Map.put(3, fn state ->
      send(state.out, {:get_input, state.id, self()})
      receive do
        {:in, x} -> 
          state
          |> Day11.update(state |> Day11.out_parameter(1), x)
          |> Day11.step_pos(2)
      end
    end)
    |> Map.put(4, fn state ->
      out = state |> Day11.get_parameter(1)
      send(state.out, {:output, state.id, out})
      state |> Day11.step_pos(2)
    end)
  end

  def route_packets(queues \\ %{}) do
    receive do
      {:get_input, id, pid} ->
        case queues[id] do
          [message | rest] ->
            send(pid, {:in, message})
            route_packets(queues |> Map.put(id, rest))
          _ ->
            send(pid, {:in, -1})
            route_packets(queues)
        end
      {:output, id, 255} ->
        receive do
          {:output, ^id, _} ->
            receive do
              {:output, ^id, y} ->
                y
            end
        end
      {:output, id, out_id} ->
        receive do
          {:output, ^id, x} ->
            receive do
              {:output, ^id, y} ->
                route_packets(queues |> Map.put(out_id, queues[out_id] ++ [x, y]))
            end
        end
      other ->
        IO.inspect other
    end
  end
end
