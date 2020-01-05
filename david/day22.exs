defmodule Day22 do
  def parse(input) do
    input
    |> String.split("\n")
    |> Stream.filter(fn x -> x != "" end)
    |> Enum.map(fn line ->
      case Regex.named_captures(~r/cut (?<cut>-?[0-9]+).*/, line) do
        %{"cut" => at} ->
          {:cut, String.to_integer(at)}
        other ->
          case Regex.named_captures(~r/deal with increment (?<deal>[0-9]+).*/, line) do
            %{"deal" => by} ->
              {:deal, String.to_integer(by)}
            other ->
              :rev
          end
      end
    end)
  end

  def shuffle(rule, deck) do
    len = deck |> Enum.count()
    case rule do
      {:cut, at} ->
        at = if at < 0 do
          len + at
        else
          at
        end
        deck
        |> Enum.drop(at)
        |> Enum.concat(deck |> Enum.take(at))
      {:deal, by} ->
        deck
        |> Stream.with_index()
        |> Enum.sort_by(fn {_, x} -> rem(x * by, len) end)
        |> Enum.map(fn {x, _} -> x end)
      :rev ->
        deck |> Enum.reverse()
    end
  end
end
