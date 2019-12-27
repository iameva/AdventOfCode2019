defmodule Day14 do
  def parse_reactions(input) do
    input
    |> String.split("\n")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.map(fn line ->
      [inputs, outputs] = line |> String.split("=>")
      %{"result" => out, "num" => num_out} = Regex.named_captures(~r/.*(?<num>\d+) (?<result>[A-Z]+)/, outputs)
        input_components = Regex.scan(~r/(\d+) ([A-Z]+)/, inputs)
        inputs = input_components
                 |> Stream.map(fn [_, num, out] ->
                   { String.to_integer(num), out }
                 end)
                 |> Enum.to_list()
        {out, %{num_out: String.to_integer(num_out), inputs: inputs}}
    end)
    |> Map.new()
  end

  def make_chemical(map, leftovers, chemical, necessary) do
    case chemical do
      "ORE" ->
        {leftovers, necessary}
      chem ->
        {leftovers, necessary} = case leftovers |> Map.get(chemical, 0) do
          existing when existing <= necessary ->
            {leftovers |> Map.delete(chemical), necessary - existing}
          existing ->
            {leftovers |> Map.put(chemical, existing - necessary), 0}
        end

        if necessary == 0 do
          {leftovers, 0}
        else
          %{num_out: num, inputs: inputs} = map[chem]
          reactions_to_run = Kernel.trunc(:math.ceil(necessary / num))
          {leftovers, ore} = Enum.reduce(inputs, {leftovers, 0}, fn {n, c}, {leftovers, ore} ->
            {l, o} = make_chemical(map, leftovers, c, n * reactions_to_run)
            {l, o + ore}
          end)
          num_created = num * reactions_to_run
          if (num_created == necessary) do
            {leftovers, ore}
          else
            {leftovers |> Map.put(chemical, (leftovers |> Map.get(chemical, 0)) + num_created - necessary), ore}
        end
        end
    end
  end

  def merge(l1, l2) do
    MapSet.union(l1 |> Map.keys(), l2 |> Map.keys())
    |> Stream.map(fn key ->
      {key, (l1 |> Map.get(key, 0)) + (l1 |> Map.get(key, 0))}
    end)
    |> Map.new()
  end

  def add({l1, o1}, {l2, o2}) do
    {merge(l1, l2), o1 + o2}
  end

  def mult({l, o}, n) do
    {l |> Stream.map(fn {k, v} -> {k, v * n} end) |> Map.new(), o * n}
  end

  def count_fuel_from_ore(reactions, ore) do
    Stream.iterate(1, &(&1 * 2))
    |> Stream.take_while(fn fuel ->
      {_, o} = make_chemical(reactions, %{}, "FUEL", fuel)
      o <= ore
    end)
    |> Enum.reverse()
    |> Enum.reduce(1, fn x, acc ->
      {_, o} = make_chemical(reactions, %{}, "FUEL", acc + x)
      if o <= ore do
        acc + x
      else
        acc
      end
      end)
  end

end
