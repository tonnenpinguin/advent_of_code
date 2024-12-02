defmodule Aoc.TwentyTwo.Day6 do
  @input File.read!(Path.join(__DIR__, "inputs/day6.txt"))

  @doc """
  ## Examples

    iex> #{__MODULE__}.part1(~s(bvwbjplbgvbhsrlpgdmjqwftvncz))
    5

    iex> #{__MODULE__}.part1(~s(nppdvjthqldpwncqszvftbrmjlhg))
    6

    iex> #{__MODULE__}.part1(~s(nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg))
    10

    iex> #{__MODULE__}.part1(~s(zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw))
    11

  """
  def part1(input \\ @input) do
    input
    |> String.to_charlist()
    |> find_marker(4)
  end

  defp find_marker(input, marker_len, idx \\ 0)
  defp find_marker([], _marker_len, _idx), do: nil

  defp find_marker(input, marker_len, idx) do
    if marker?(input, marker_len) do
      idx + marker_len
    else
      input
      |> Enum.drop(1)
      |> find_marker(marker_len, idx + 1)
    end
  end

  defp marker?(input, marker_len) do
    input
    |> Enum.take(marker_len)
    |> Enum.uniq()
    |> Enum.count()
    |> Kernel.==(marker_len)
  end

  @doc """
  ## Examples

    iex> #{__MODULE__}.part2(~s(mjqjpqmgbljsphdztnvjfqwrcgsmlb))
    19

    iex> #{__MODULE__}.part2(~s(bvwbjplbgvbhsrlpgdmjqwftvncz))
    23

    iex> #{__MODULE__}.part2(~s(nppdvjthqldpwncqszvftbrmjlhg))
    23

    iex> #{__MODULE__}.part2(~s(nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg))
    29

    iex> #{__MODULE__}.part2(~s(zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw))
    26

  """
  def part2(input \\ @input) do
    input
    |> String.to_charlist()
    |> find_marker(14)
  end
end
