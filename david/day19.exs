defmodule Day19 do
  def run(code, input) do
    Day17.process(code |> Map.put(:input, input), Day17.opcodes(false)).output
  end
end
