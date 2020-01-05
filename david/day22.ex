Day22.parse(File.read!("data/day22"))
|> Enum.reduce(0..10006, &Day22.shuffle/2)
|> Stream.with_index
|> Enum.find(fn {x, _} -> x == 2019 end)
|> IO.inspect

