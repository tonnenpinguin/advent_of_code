defmodule Aoc.TwentyTwo.Day1 do
  @input File.read!(Path.join(__DIR__, "inputs/day1.txt"))

  @doc """
  Find the elf with the most calories

  ## Examples

    iex> #{__MODULE__}.part1(~s(1000\\n2000\\n3000\\n\\n4000\\n\\n5000\\n6000\\n\\n7000\\n8000\\n9000\\n\\n10000))
    24000

  """
  def part1(input \\ @input) do
    input
    |> calculate_elf_calories()
    |> find_max()
  end

  defp calculate_elf_calories(input_str) when is_binary(input_str) do
    input_str
    |> String.split("\n\n")
    |> Enum.map(&calculate_calories_per_elf/1)
  end

  defp calculate_calories_per_elf(elf_lines) do
    elf_lines
    |> String.split("\n")
    |> Enum.reduce(0, fn str_calories, acc ->
      {parsed_calories, _rem} = Integer.parse(str_calories)
      acc + parsed_calories
    end)
  end

  defp find_max(calories) do
    Enum.max(calories)
  end

  @doc """
  Get the sum of the three top elfes

  ## Examples

    iex> #{__MODULE__}.part2(~s(1000\\n2000\\n3000\\n\\n4000\\n\\n5000\\n6000\\n\\n7000\\n8000\\n9000\\n\\n10000))
    45000

  """
  def part2(input \\ @input) do
    input
    |> calculate_elf_calories()
    |> find_top_3()
    |> Enum.sum()
  end

  defp find_top_3(calories) do
    calories
    |> Enum.sort(:desc)
    |> Enum.take(3)
  end
end
