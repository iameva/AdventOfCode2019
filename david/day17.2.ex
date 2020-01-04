code = Day17.parse_state(File.read!("data/day17"))

program = code |> Day11.update(0, 2)

Day17.process(program)

#
#IO.puts "program state #{program.state}"
#
#main = IO.gets("Main Routine? ")
#a = IO.gets("Routine A? ")
#b = IO.gets("Routine B? ")
#c = IO.gets("Routine C? ")
#
#all = main <> a <> b <> c
#IO.puts "all: #{inspect to_charlist(all)}"
#program = Day17.slow_input(program, to_charlist(all))
#
#IO.puts("program state #{program.state}")
#


