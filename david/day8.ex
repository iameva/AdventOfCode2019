{layer, _} = 
  File.read!("data/day8")
  |> String.trim()
  |> String.codepoints()
  |> Enum.map(&String.to_integer/1)
  |> Enum.chunk_every(25*6)
  |> Enum.with_index()
  |> Enum.min_by(fn {layer, zip} -> layer |> Stream.filter(&(&1 == 0)) |> Enum.count() end)

ones = layer |> Stream.filter(&(&1 == 1)) |> Enum.count
twos = layer |> Stream.filter(&(&1 == 2)) |> Enum.count

IO.puts "#{ones * twos}"
