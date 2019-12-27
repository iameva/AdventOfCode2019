defmodule Day15 do
  def start_program(code) do
    spawn_link fn () -> Day11.process(code, Day11.opcodes()) end
  end

  # 1, 2, 3, 4 = north, south, east, west
  # result: 
  #   0: hit wall
  #   1: moved successfully
  #   2: moved and found oxygen system (the goal)
  def move(pid, dir) do
    send(pid, {:input, dir})
    receive do
      {:input, result} -> result
    end
  end

  #up, right, down, left
  @directions = [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]

  def create_map(pid) do
    map = %{{0, 0}, 1}

  end
end
