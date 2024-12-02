defmodule Aoc.TwentyTwo.Day3 do
  @input File.read!(Path.join(__DIR__, "inputs/day3.txt"))

  @doc """
  ## Examples

    iex> #{__MODULE__}.part1(~s(vJrwpWtwJgWrhcsFMMfFFhFp\\njqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL\\nPmmdzqPrVvPwwTWBwg\\nwMqvLMZHhHMvwLHjbvcjnnSBnvTQFn\\nttgJtRGJQctTZtZT\\nCrZsJsPPZsGzwwsLwLmpwMDw))
    157

  """
  def part1(input \\ @input) do
    input
    |> parse_input()
    |> Enum.map(&split_compartments/1)
    |> Enum.map(&find_common_item/1)
    |> Enum.map(&score_item/1)
    |> Enum.sum()
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
  end

  defp split_compartments(line) do
    len = String.length(line)
    String.split_at(line, round(len / 2))
  end

  defp find_common_item({comp1, comp2}) do
    MapSet.intersection(
      to_mapset(comp1),
      to_mapset(comp2)
    )
    |> MapSet.to_list()
    |> Enum.at(0)
  end

  defp find_common_item([bag1, bag2, bag3]) do
    MapSet.intersection(
      to_mapset(bag1),
      to_mapset(bag2)
    )
    |> MapSet.intersection(to_mapset(bag3))
    |> MapSet.to_list()
    |> Enum.at(0)
  end

  defp to_mapset(str), do: str |> String.to_charlist() |> MapSet.new()

  defp score_item(item) when item >= ?a and item <= ?z, do: item - ?a + 1
  defp score_item(item) when item >= ?A and item <= ?Z, do: item - ?A + 27

  @doc """
    ## Examples

      iex> #{__MODULE__}.part2(~s(vJrwpWtwJgWrhcsFMMfFFhFp\\njqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL\\nPmmdzqPrVvPwwTWBwg\\nwMqvLMZHhHMvwLHjbvcjnnSBnvTQFn\\nttgJtRGJQctTZtZT\\nCrZsJsPPZsGzwwsLwLmpwMDw))
      70

  """
  def part2(input \\ @input) do
    input
    |> parse_input()
    |> Enum.chunk_every(3)
    |> Enum.map(&find_common_item/1)
    |> Enum.map(&score_item/1)
    |> Enum.sum()
  end
end
