len = 119315717514047
shuffles = 101741582076661

Day22.parse(File.read!("data/day22"))
|> Day22.part_two(len, shuffles, 2020)
|> IO.inspect
