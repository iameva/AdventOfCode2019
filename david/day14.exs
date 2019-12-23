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
          {leftovers, ore} = Enum.reduce(inputs, {leftovers, 0}, fn {n, c}, {leftovers, ore} ->
            {l, o} = make_chemical(map, leftovers, c, n)
            {l, o + ore}
          end)
          if (num < necessary) do
            {l, o} = make_chemical(map, leftovers, chemical, necessary - num)
            {l, o + ore}
          else
            if (num == necessary) do
              {leftovers, ore}
            else
              {leftovers |> Map.put(chemical, (leftovers |> Map.get(chemical, 0)) + num - necessary), ore}
            end
        end
        end
    end
  end
end
