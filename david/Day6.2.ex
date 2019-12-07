orbits = Day6.parse_orbits(File.read!("data/day6"))
me = "YOU"
santa = "SAN"

lineage = fn (obj) ->
    Stream.iterate(orbits[obj], &(orbits[&1]))
    |> Stream.take_while(&(&1 != nil))
  end

my_lin = lineage.(me)
santa_lin = lineage.(santa)

my_lineage = MapSet.new(my_lin)

[common_ancestor] = santa_lin |> Stream.filter(&(MapSet.member?(my_lineage, &1))) |> Enum.take(1)

idx_of = fn (obj, stream) ->
    [{_, idx}] = Stream.with_index(stream)
    |> Stream.filter(fn {a, _} -> a == obj end)
    |> Enum.take(1)
    idx
  end

IO.puts idx_of.(common_ancestor, santa_lin) + idx_of.(common_ancestor, my_lin)

