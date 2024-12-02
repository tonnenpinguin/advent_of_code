defmodule Aoc.TwentyTwo.Day4 do
  @input File.read!(Path.join(__DIR__, "inputs/day4.txt"))

  @doc """
  ## Examples

    iex> #{__MODULE__}.part1(~s(2-4,6-8\\n2-3,4-5\\n5-7,7-9\\n2-8,3-7\\n6-6,4-6\\n2-6,4-8))
    2

  """
  def part1(input \\ @input) do
    input
    |> parse_input()
    |> Enum.map(&parse_range/1)
    |> Enum.chunk_every(2)
    |> Enum.filter(&overlapping_pair?/1)
    |> Enum.count()
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.flat_map(&String.split(&1, ","))
  end

  defp parse_range(str) do
    String.split(str, "-")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp overlapping_pair?([{from_a, to_a}, {from_b, to_b}]) when from_a <= from_b and to_a >= to_b,
    do: true

  defp overlapping_pair?([{from_a, to_a}, {from_b, to_b}]) when from_a >= from_b and to_a <= to_b,
    do: true

  defp overlapping_pair?(_other), do: false

  @doc """
  ## Examples

    iex> #{__MODULE__}.part2(~s(2-4,6-8\\n2-3,4-5\\n5-7,7-9\\n2-8,3-7\\n6-6,4-6\\n2-6,4-8))
    4

  """
  def part2(input \\ @input) do
    input
    |> parse_input()
    |> Enum.map(&parse_range/1)
    |> Enum.chunk_every(2)
    |> Enum.reject(&no_overlap?/1)
    |> Enum.count()
  end

  defp no_overlap?([{from_a, to_a}, {from_b, to_b}]) when to_a < from_b or to_b < from_a,
    do: true

  defp no_overlap?(_other), do: false
end
