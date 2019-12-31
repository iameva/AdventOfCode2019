code = Day11.parse_state(File.read!("data/day17"))

pid = Day15.start_program(code |> Day11.update(0, 2))
size = 1925

main_routine = IO.gets("Main Routine? ")
String.codepoints(main_routine) |> Enum.each(fn <<x>> ->
  IO.puts(x)
  send(pid, {:input, x}) end)

routine_a = IO.gets("Routine A? ")
String.codepoints(routine_a) |> Enum.each(fn <<x>> -> 
  IO.puts(x)
  send(pid, {:input, x}) end)
routine_b = IO.gets("Routine B? ")
String.codepoints(routine_b) |> Enum.each(fn <<x>> -> IO.puts(x)
  send(pid, {:input, x}) end)
routine_c = IO.gets("Routine C? ")
String.codepoints(routine_c) |> Enum.each(fn <<x>> -> IO.puts(x)
  send(pid, {:input, x}) end)


<<y>> = "y"
send(pid, {:input, y})

Day17.read_state(%{}, {0, 0}, size)




