in_program = Day11.parse_state(File.read!("data/day13"))

program = in_program |> Day11.update(in_program.offset, 2)
pid = spawn_link fn -> Day11.process(program, Day11.opcodes()) end
send(pid, {:set_output, self()})

get_output = fn () -> 
  receive do
    {:input, p} ->
      p
    other -> other
  end
end

print_state = fn (state, score) ->
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
  IO.puts("score #{score}")
  IO.puts("")
end


handle_result = fn (state, score, f) ->
  if(state |> Enum.count() > 0, do: print_state.(state, score))
#  :timer.sleep(15)
  case get_output.() do
    :halted -> 
      state
    -1 ->
      _dummy_y = get_output.()
      score = get_output.()
      f.(state, score, f)
    x ->
      y = get_output.()
      tile = get_output.()
      f.(state |> Map.put({x, y}, tile), score, f)
  end
end

get_input = fn (f) ->
  input = IO.getn("", 2)
  IO.puts("GOT INPUT: #{input}")
  case input do
    "h\n" -> 
      send(pid, {:input, -1})
      f.(f)
    "l\n" ->
      send(pid, {:input, 1})
      f.(f)
    "x\n" ->
      ()
    _ ->
      send(pid, {:input, 0})
      f.(f)
  end
end

spawn_link fn() -> get_input.(get_input) end


handle_result.(%{}, 0, handle_result)

