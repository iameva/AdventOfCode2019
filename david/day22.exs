defmodule Day22 do
  import Integer

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
        |> Enum.sort_by(fn {_, x} -> mod(x * by, len) end)
        |> Enum.map(fn {x, _} -> x end)
      :rev ->
        deck |> Enum.reverse()
    end
  end

  def mod_inverse(a, b, {s, s0, t, t0} \\ {0, 1, 1, 0}) do
    {r, r0} = {b, a}
    if r == 0 do
      s0
    else
      q = div(a, b)
      {r0, r} = {b, a - q * b}
      {s0, s} = {s, s0 - q * s}
      {t0, t} = {t, t0 - q * t}
      mod_inverse(r0, r, {s, s0, t, t0})
    end
  end

  # construct a linear function of the form f(x) -> a*x + b that reverses a position
  # based on a rule.
  def reverse_rule(len, rule) do
    case rule do
      {:cut, at} ->
        case at do
          _ when at < 0 -> {1, len + at}
          _ when at >= 0 -> {1, at}
        end
      {:deal, by} ->
        inv = mod_inverse(by, len)
        inv = if (inv < 0) do
          inv + len
        else
          inv
        end
        {inv, 0}
      :rev ->
        {-1, len - 1}
    end
  end

  # f and g are of the form {a, b} representing the function f(x) = (a * x) + b
  def compose(f, g, len) do # -> f(g(x))
    {a, b} = f
    {c, d} = g
    {mod(a * c, len), mod(a * d + b, len)}
  end

  def execute_times({a, b}, len, times) when times > 0 do
    case times do
      1 ->
        {a, b}
      x when rem(x, 2) == 0 ->
        # execute f(f(x)) times/2 times
        execute_times({mod(a * a, len), mod(a * b + b, len)}, len, div(times, 2))
      _ ->
        {c, d} = execute_times({a, b}, len, times - 1)
        {mod(a * c, len), mod(a * d + b, len)}
    end
  end

  def execute({a, b}, len, x) do
    mod(a * x + b, len)
  end

  def part_two(rules, len, iterations, position) do
    rules
    |> Enum.reverse
    |> Enum.map(&(reverse_rule(len, &1)))
    |> Enum.reduce({1, 0}, &(compose(&1, &2, len)))
    |> execute_times(len, iterations)
    |> execute(len, position)
  end
end
