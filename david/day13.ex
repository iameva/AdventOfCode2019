program = Day11.parse_state(File.read!("data/day13"))
pid = spawn_link fn -> Day11.process(program, Day11.opcodes()) end
send(pid, {:set_output, self()})

get_output = fn () -> 
  receive do
    {:input, p} ->
      p
    other -> other
  end
end

handle_result = fn (state, f) ->
  case get_output.() do
    :halted -> 
      state
    x ->
      y = get_output.()
      tile = get_output.()
      f.(state |> Map.put({x, y}, tile), f)
  end
end

result = handle_result.(%{}, handle_result)


startX = (result |> Map.keys() |> Stream.map(fn {x, _} -> x end) |> Enum.min()) - 1
startY = (result |> Map.keys() |> Stream.map(fn {_, y} -> y end) |> Enum.min()) - 1
endX = (result |> Map.keys() |> Stream.map(fn {x, _} -> x end) |> Enum.max()) + 1
endY = (result |> Map.keys() |> Stream.map(fn {_, y} -> y end) |> Enum.max()) + 1

for y <- startY..endY,
    x <- startX..endX do
  if x == startX do
    IO.write("\n")
  end
  case result |> Map.get({x, y}) do
    1 -> IO.write("0")
    2 -> IO.write("I")
    3 -> IO.write("-")
    4 -> IO.write("O")
    _ -> IO.write(" ")
  end
end

IO.puts("")
num_blocks = result |> Map.values() |> Stream.filter(&(&1 == 2)) |> Enum.count()

IO.puts "#{num_blocks} blocks"
