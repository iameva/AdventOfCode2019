defmodule Vec do
  def add(a, b) do
     Enum.zip(Tuple.to_list(a), Tuple.to_list(b))
     |> Enum.map(fn {a, b} -> a + b end)
     |> List.to_tuple()
  end
  def to_ones(vec) do
    vec
    |> Tuple.to_list()
    |> Enum.map(fn (x) -> if(x > 0, do: 1, else: if(x < 0, do: -1, else: 0)) end)
    |> List.to_tuple()
  end
  def sub(a, b) do
    Enum.zip(Tuple.to_list(a), Tuple.to_list(b))
    |> Enum.map(fn {a, b} -> a - b end)
    |> List.to_tuple()
  end
  def energy(a) do
    Tuple.to_list(a) |> Stream.map(&Kernel.abs/1) |> Enum.sum
  end
end

defmodule Day12 do
  def parse_moons(input) do
    input
    |> String.split("\n")
    |> Stream.filter(&(&1 != ""))
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Enum.map(fn {line, idx} ->
        captured = Regex.named_captures(~r/<x=(?<x>-?\d+).*y=(?<y>-?\d+).*z=(?<z>-?\d+)>/, line)
          {
            idx,
            %{
              :pos => {
                String.to_integer(captured["x"]),
                String.to_integer(captured["y"]),
                String.to_integer(captured["z"])
              },
              :vel => {0, 0, 0}
            }
          }
      end)
    |> Map.new()
  end

  def step_gravity(moons) do
    moons
    |> Stream.map(fn {idx, moon} ->
      others = moons |> Map.delete(idx)
      new_velocity = others |> Enum.reduce(moon.vel, fn {_, o}, vel -> Vec.sub(o.pos, moon.pos) |> Vec.to_ones() |> Vec.add(vel) end)
      {idx, %{moon | :vel => new_velocity}}
    end)
    |> Map.new()
  end

  def step_velocity(moons) do
    moons
    |> Stream.map(fn {idx, moon} -> {idx, %{moon | pos: Vec.add(moon.pos, moon.vel)}} end)
    |> Map.new()
  end

  def step(moons) do
    moons
    |> step_gravity()
    |> step_velocity()
  end

  def energy(%{ :vel => vel, :pos => pos}) do
    Vec.energy(vel) * Vec.energy(pos)
  end

  def energy(moons) do
    moons |> Stream.map(fn {_, moon} -> energy(moon) end) |> Enum.sum()
  end
end
