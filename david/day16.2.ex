base_signal = Day16.parse_input(File.read!("data/day16"))
signal = 1..10000
         |> Stream.flat_map(fn _ -> base_signal end)
         |> Enum.to_list()

len = signal |> Enum.count()

hundredth = Stream.iterate(signal, fn s -> Day16.fft2(s, len) end)
            |> Enum.at(100)

IO.puts "100th iteration: #{inspect hundredth}"
