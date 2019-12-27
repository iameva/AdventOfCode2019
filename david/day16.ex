signal = Day16.parse_input(File.read!("data/day16"))
IO.puts inspect signal
hundredth = Stream.iterate(signal, &Day16.fft/1)
            |> Enum.at(100)

IO.puts "100th iteration: #{inspect hundredth}"
