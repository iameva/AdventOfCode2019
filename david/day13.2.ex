program = Day11.parse_state(File.read!("data/day13")) |> Day11.update(0, 2)
pid = spawn_link fn -> Day11.process(program, Day11.opcodes()) end
send(pid, {:set_output, self()})

get_output = fn () -> 
  receive do
    {:input, p} ->
      p
    other -> other
  end
end

print_state = fn (state) ->
  startX = (state |> Map.keys() |> Stream.map(fn {x, _} -> x end) |> Enum.min()) - 1
  startY = (state |> Map.keys() |> Stream.map(fn {_, y} -> y end) |> Enum.min()) - 1
  endX = (state |> Map.keys() |> Stream.map(fn {x, _} -> x end) |> Enum.max()) + 1
  endY = (state |> Map.keys() |> Stream.map(fn {_, y} -> y end) |> Enum.max()) + 1
  
  for y <- 0..endY,
      x <- startX..endX do
    if x == startX do
      IO.write("\n")
    end
    case state |> Map.get({x, y}) do
      1 -> IO.write("0")
      2 -> IO.write("I")
      3 -> IO.write("-")
      4 -> IO.write("O")
      _ -> IO.write(" ")
    end
  end
  IO.puts("")
end

input_pid = spawn_link fn () ->
  get_input = fn (f) ->
    input = IO.gets("")
    inp = case input do
      "h" -> -1
      "l" -> 1
      _ -> 0
    end
      IO.puts("got input #{input}")
    send(pid, {:input, inp})
    f.(f)
  end
    get_input.(get_input)
end

handle_result = fn (state, f) ->
  case get_output.() do
    :halted -> 
      state
    -1 ->
      _dummy_y = get_output.()
      score = get_output.()
      print_state.(state)
      IO.puts ("score: #{score}")
      IO.puts("")
      f.(state, f)
    x ->
      y = get_output.()
      tile = get_output.()
      f.(state |> Map.put({x, y}, tile), f)
  end
end

result = handle_result.(%{}, handle_result)

