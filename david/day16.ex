signal = Day16.parse_input(File.read!("data/day16"))

len = signal |> Enum.count()

hundredth = Stream.iterate(signal, fn s -> Day16.fft2(s, len) end)
            |> Enum.at(100)

IO.puts "100th iteration: #{inspect hundredth}"
