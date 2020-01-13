code = Day17.parse_state(File.read!("data/day25"))

code
|> Day17.process(Day17.opcodes(true))
|> IO.inspect

# tambourine
# space heater
