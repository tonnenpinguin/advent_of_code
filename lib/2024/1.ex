import AOC

aoc 2024, 1 do
  @moduledoc """
  https://adventofcode.com/2024/day/1
  """

  @doc """
      iex> p1(example_string())
      11

      iex> p1(input_string())
  """
  def p1(input) do
    {a, b} = parse(input)

    a = Enum.sort(a)
    b = Enum.sort(b)

    # Within each pair, figure out how far apart the two numbers are; you'll need to add up all of those distances.
    # For example, if you pair up a 3 from the left list with a 7 from the right list, the distance apart is 4; if you pair up a 9 with a 3, the distance apart is 6.
    Enum.zip(a, b)
    |> Enum.map(fn {a, b} -> abs(b - a) end)
    # To find the total distance between the left list and the right list, add up the distances between all of the pairs you found
    |> Enum.sum()
  end

  @doc """
      iex> p2(example_string())
      31

      iex> p2(input_string()) |> dbg()
  """
  def p2(input) do
    {a, b} = parse(input)

    b_freq = Enum.frequencies(b)

    a
    |> Enum.map(fn val -> val * Map.get(b_freq, val, 0) end)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ~r(\s+)))
    |> Enum.reduce({[], []}, fn [a, b], {acc_a, acc_b} ->
      {[String.to_integer(a) | acc_a], [String.to_integer(b) | acc_b]}
    end)
  end
end
