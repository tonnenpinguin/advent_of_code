defmodule Aoc.TwentyTwo.Day2 do
  @input File.read!(Path.join(__DIR__, "inputs/day2.txt"))

  @doc """
  Score the rock paper scissor strategy

  ## Examples

    iex> #{__MODULE__}.part1(~s(A Y\\nB X\\nC Z))
    15

  """
  def part1(input \\ @input) do
    input
    |> String.split("\n")
    |> Enum.map(&parse_round_part_1/1)
    |> Enum.map(&score_round/1)
    |> Enum.sum()
  end

  defp parse_round_part_1(<<them, " ", us>>) do
    them = parse_shape(them)
    us = parse_shape(us)
    {them, us}
  end

  defp score_round({them, us}) do
    get_result(them, us)
    |> score_result()
    |> Kernel.+(score_shape(us))
  end

  defp parse_shape(shape) do
    case shape do
      s when s in [?A, ?X] -> :rock
      s when s in [?B, ?Y] -> :paper
      s when s in [?C, ?Z] -> :scissors
    end
  end

  defp get_result(shape, shape), do: :draw
  defp get_result(:rock = _them, :scissors = _us), do: :lose
  defp get_result(:scissors = _them, :paper = _us), do: :lose
  defp get_result(:paper = _them, :rock = _us), do: :lose
  defp get_result(_them, _us), do: :win

  defp score_shape(:rock), do: 1
  defp score_shape(:paper), do: 2
  defp score_shape(:scissors), do: 3

  defp score_result(:lose), do: 0
  defp score_result(:draw), do: 3
  defp score_result(:win), do: 6

  @doc """
  Score the rock paper scissor strategy

  ## Examples

    iex> #{__MODULE__}.part2(~s(A Y\\nB X\\nC Z))
    12

  """
  def part2(input \\ @input) do
    input
    |> String.split("\n")
    |> Enum.map(&parse_round_part_2/1)
    |> Enum.map(&score_round/1)
    |> Enum.sum()
  end

  defp parse_round_part_2(<<them, " ", result>>) do
    them = parse_shape(them)
    result = parse_result(result)

    us = find_our_shape_for_result(them, result)

    {them, us}
  end

  defp find_our_shape_for_result(them, result) do
    Enum.find([:rock, :paper, :scissors], fn us ->
      get_result(them, us) == result
    end)
  end

  defp parse_result(result) do
    case result do
      ?X -> :lose
      ?Y -> :draw
      ?Z -> :win
    end
  end
end
