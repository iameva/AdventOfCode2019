input_str = File.read!("data/day16")
base_signal = Day16.parse_input(input_str)
signal = 1..10000
         |> Stream.flat_map(fn _ -> base_signal end)
         |> Enum.to_list()
offset = input_str |> String.slice(0..6) |> String.to_integer()
len = signal |> Enum.count()
IO.puts "offset: #{offset} len: #{len}"

end_of_signal = signal |> Enum.drop(offset)

hundredth = Stream.iterate(end_of_signal, fn s -> Day16.fft_simple(s) end)
            |> Enum.at(100)

IO.puts "100th iteration: #{inspect hundredth}"
