defmodule Aoc.TwentyOne.Day1 do
  @input File.read!(Path.join(__DIR__, "inputs/day1.txt"))

  @doc """
  Calculate the number of increases

  ## Examples

      iex> #{__MODULE__}.part1(~s(199\\n200\\n208\\n210\\n200\\n207\\n240\\n269\\n260\\n263))
      7

  """
  def part1(input \\ @input) do
    input
    |> parse()
    |> count_single()
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  defp count_single(input, result \\ 0)
  defp count_single([_last], result), do: result

  defp count_single([a, b | rest], result) do
    result = if a < b, do: result + 1, else: result
    count_single([b] ++ rest, result)
  end

  @doc """
  Calculate the number of increases in a sliding window

  ## Examples

      iex> #{__MODULE__}.part2(~s(199\\n200\\n208\\n210\\n200\\n207\\n240\\n269\\n260\\n263))
      5

  """
  def part2(input \\ @input) do
    input
    |> parse()
    |> count_multi()
  end

  defp count_multi(input, result \\ 0)
  defp count_multi([_last1, _last2, _last3], result), do: result

  defp count_multi([a, b, c, d | rest], result) do
    result = if a + b + c < b + c + d, do: result + 1, else: result
    count_multi([b, c, d] ++ rest, result)
  end
end
