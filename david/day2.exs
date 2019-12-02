defmodule Day2 do
  def parse_state(str) do
    String.split(str, ",")
      |> Stream.map(&String.trim/1)
      |> Stream.filter(&(&1 != ""))
      |> Stream.map(&String.to_integer/1)
      |> Stream.with_index
      |> Stream.map(fn({a, b}) -> {b, a} end)
      |> Map.new
  end
  def load_state(file) do
    parse_state(File.read!(file))
  end
  def process(state, position) do
    case state[position] do
      1 ->
        added = state[state[position + 1]] + state[state[position + 2]]
        newState = %{state | state[position + 3] => added}
        process(newState, position + 4)
      2 ->
        multiplied = state[state[position + 1]] * state[state[position + 2]]
        newState = %{state | state[position + 3] => multiplied}
        process(newState, position + 4)
      99 ->
        state
    end
  end
end
