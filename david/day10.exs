defmodule Day10 do

  def parse_map(input) do
    String.split(input, "\n")
    |> Enum.map(&String.trim/1)
    |> Stream.with_index(0)
    |> Enum.flat_map(fn {a, y} ->
        String.codepoints(a)
        |> Stream.with_index(0)
        |> Enum.flat_map(fn {char, x} ->
            if char == "#", do: [{x, y}], else: []
          end)
      end)
    |> MapSet.new()
  end

  def gcd(a, b) do
    small = if (a > b), do: a, else: b
    try do
      1..small
      |> Enum.filter(&( (rem(a, &1) == 0) && (rem(b, &1) == 0)))
      |> Enum.max()
    catch
      _ -> nil
    end
  end

  def simplified_vector({x, y}) do
    val = gcd(Kernel.abs(x), Kernel.abs(y))
    if val == nil, do: {x, y}, else: {div(x, val), div(y, val)}
  end

  def sub({x1, y1}, {x2, y2}) do
    {x1 - x2, y1 - y2}
  end

  def magnitude({x, y}) do
    :math.sqrt(x * x + y * y)
  end

  def find_most_visible(points) do
    points
    |> Stream.map(fn p ->
        {p, points
        |> Stream.filter(&(&1 != p))
        |> Stream.map(&(simplified_vector(sub(&1, p))))
        |> MapSet.new()
        |> Enum.count()}
      end)
    |> Enum.max_by(fn {_, b} -> b end)
  end

  def to_pos(theta) do
    if (theta < 0), do: (:math.pi * 2) + theta, else: theta
  end

  def to_angle({x, y}) do
    to_pos((:math.pi / 2) - to_pos(:math.atan2(y, x)))
  end

end
