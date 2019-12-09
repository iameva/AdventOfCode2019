defmodule Day8 do
  def write_image(data_in, rows, cols) do
    data = data_in |> String.codepoints()
    len = rows * cols
    for row <- 0..rows - 1,
        col <- 0..cols - 1 do
      idx = row * cols + col
      char = data
        |> Stream.drop(idx)
        |> Stream.take_every(len)
        |> Enum.find(fn (c) -> c != "2" end)
      case char do
        "1" -> IO.write("0")
        "0" -> IO.write(" ")
        _ -> IO.write("3")
      end
      if (col == cols - 1) do
        IO.write("\n")
      end
    end
    IO.write("\n")
  end
end
