program = Day11.parse_state(File.read!("data/day11"))
pid = spawn_link fn ->
  Day11.process(program, Day11.opcodes())
end

send(pid, {:set_output, self()})

state = %{:pos => {0, 0}, :dir => :up, painted: %{{0, 0} => true}}

turn = fn(dir, turn) ->
  case turn do
    :left ->
      case dir do
        :up -> :left
        :down -> :right
        :left -> :down
        :right -> :up
      end
    :right ->
      case dir do
        :up -> :right
        :down -> :left
        :left -> :up
        :right -> :down
      end
  end
end

step = fn(pos, dir) ->
  vec = case dir do
      :up -> {0, 1}
      :left -> {-1, 0}
      :right -> {1, 0}
      :down -> {0, -1}
    end
  Day11.add(pos, vec)
end

process = fn (state, f) ->
  paint = if Map.get(state.painted, state.pos, false), do: 1, else: 0
  send(pid, {:input, paint})
  receive do
    {:input, newPaint} ->
      state = case newPaint do
        1 -> state |> Map.put(:painted, state.painted |> Map.put(state.pos, true))
        _ -> state |> Map.put(:painted, state.painted |> Map.put(state.pos, false))
      end
      receive do
        {:input, inDir} ->
          t = if inDir == 0, do: :left, else: :right
          nextDir = turn.(state.dir, t)
          next_state = state
            |> Map.put(:pos, step.(state.pos, nextDir))
            |> Map.put(:dir, nextDir)
          f.(next_state, f)
      end
    :halted ->
      IO.puts "haulted"
      state
  end
end

result = process.(state, process)
IO.puts Enum.count(result.painted)

startX = (result.painted |> Map.keys() |> Stream.map(fn {x, _} -> x end) |> Enum.min()) - 1
startY = (result.painted |> Map.keys() |> Stream.map(fn {_, y} -> y end) |> Enum.min()) - 1
endX = (result.painted |> Map.keys() |> Stream.map(fn {x, _} -> x end) |> Enum.max()) + 1
endY = (result.painted |> Map.keys() |> Stream.map(fn {_, y} -> y end) |> Enum.max()) + 1

for y <- endY..startY,
    x <- startX..endX do
  if x == startX do
    IO.write("\n")
  end
  case result.painted |> Map.get({x, y}) do
    true -> IO.write("0")
    false -> IO.write("-")
    nil -> IO.write(" ")
  end
end
IO.write("\n")

