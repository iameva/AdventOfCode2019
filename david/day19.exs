defmodule Day19 do
  def run(code, input) do
    Day17.process(code |> Map.put(:input, input), Day17.opcodes(false)).output
  end
  def check?(code, {x, y}) do
    r = Day17.process(code |> Map.put(:input, [x, y]), Day17.opcodes(false)).output
    |> Enum.at(0)
    r == 1
  end
  def neighbors({x, y}) do
    l = [-1, 0, 1]
    l |> Stream.flat_map(fn dx ->
      l |> Stream.map(fn dy ->
        {x + dx, y + dy}
      end)
    end)
    |> Stream.filter(&({x, y} != &1))
    |> Enum.to_list
  end
end
