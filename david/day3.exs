defmodule Point do
  @enforce_keys [:x, :y]
  defstruct [:x, :y]

  def zero do
    %Point{x: 0, y: 0}
  end

  def add(p1, p2) do
    %Point{x: p1.x + p2.x, y: p1.y + p2.y}
  end

  def dist(point), do: Kernel.abs(point.x) + Kernel.abs(point.y)
end

defmodule Step do
  @enforce_keys [:dir, :dist]
  defstruct [:dir, :dist]

  def dir_to_point(:up), do: %Point{x: 0, y: 1}
  def dir_to_point(:down), do: %Point{x: 0, y: -1}
  def dir_to_point(:left), do: %Point{x: -1, y: 0}
  def dir_to_point(:right), do: %Point{x: 1, y: 0}
end

defmodule Wire do
  @enforce_keys [:steps]
  defstruct [:steps]

  def points(wire) do
    points =
      for step <- wire.steps,
          dir = Step.dir_to_point(step.dir),
          point <- Stream.cycle([dir]) |> Stream.take(step.dist) do
        point
      end
    Stream.scan(points, Point.zero, &Point.add/2)
  end
end

defmodule Day3 do
  @upMatch ~r/U(?<up>\d+)/
  @downMatch ~r/D(?<down>\d+)/
  @rightMatch ~r/R(?<right>\d+)/
  @leftMatch ~r/L(?<left>\d+)/
  
  @all [@upMatch, @downMatch, @rightMatch, @leftMatch]

  def parse_step(str) do
    matched = Stream.map(@all, &(Regex.named_captures(&1, str))) |>
      Stream.filter(&(&1 != nil)) |>
      Enum.take(1)

    case matched do
      [%{"right" => num}] ->
        %Step{dir: :right, dist: String.to_integer(num)}
      [%{"up" => num}] ->
        %Step{dir: :up, dist: String.to_integer(num)}
      [%{"down" => num}] ->
        %Step{dir: :down, dist: String.to_integer(num)}
      [%{"left" => num}] ->
        %Step{dir: :left, dist: String.to_integer(num)}
    end
  end

  def parse_wire(line) do
    %Wire{steps: String.split(line, ",")
      |> Enum.map(&parse_step/1)}
  end

  def parse_wires(text) do
    String.split(text, "\n")
      |> Stream.filter(&(&1 != ""))
      |> Enum.map(&parse_wire/1)
  end

  def find_closest_intersection(wire1, wire2) do
    wire1_points = MapSet.new(Wire.points(wire1))
    wire2_points = MapSet.new(Wire.points(wire2))
    intersections = MapSet.intersection(wire1_points, wire2_points)
    Enum.min_by(intersections, &Point.dist/1)
  end

  def find_steps_to_soonest_intersection(wire1, wire2) do
    p1 = Wire.points(wire1)
    p2 = Wire.points(wire2)
    m1 = Map.new(Stream.with_index(p1, 1))
    m2 = Map.new(Stream.with_index(p2, 1))
    intersection_points = MapSet.intersection(MapSet.new(p1), MapSet.new(p2))
    
    point = Enum.min_by(intersection_points, fn p -> m1[p] + m2[p] end)
    m1[point] + m2[point]
  end
end
