defmodule Aoc.TwentyOne.Day2 do
  @input File.read!(Path.join(__DIR__, "inputs/day2.txt"))
  @doc """
  ## Examples

      iex> #{__MODULE__}.part1(~s(forward 5\\ndown 5\\nforward 8\\nup 3\\ndown 8\\nforward 2))
      150
  """
  def part1(input \\ @input) do
    parsed_input = parse(input)
    {horizontal, vertical} = calculate_simple(parsed_input)
    horizontal * vertical
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      [command, units] = String.split(line, " ")
      [command, String.to_integer(units)]
    end)
  end

  defp calculate_simple(_commands, horizontal \\ 0, vertical \\ 0)
  defp calculate_simple([], horizontal, vertical), do: {horizontal, vertical}

  defp calculate_simple([["forward", units] | rest], horizontal, vertical),
    do: calculate_simple(rest, horizontal + units, vertical)

  defp calculate_simple([["up", units] | rest], horizontal, vertical),
    do: calculate_simple(rest, horizontal, vertical - units)

  defp calculate_simple([["down", units] | rest], horizontal, vertical),
    do: calculate_simple(rest, horizontal, vertical + units)

  @doc """
  ## Examples

      iex> #{__MODULE__}.part2(~s(forward 5\\ndown 5\\nforward 8\\nup 3\\ndown 8\\nforward 2))
      900
  """
  def part2(input \\ @input) do
    parsed_input = parse(input)
    {horizontal, vertical} = calculate_complex(parsed_input)
    horizontal * vertical
  end

  defp calculate_complex(_commands, horizontal \\ 0, vertical \\ 0, aim \\ 0)
  defp calculate_complex([], horizontal, vertical, _aim), do: {horizontal, vertical}

  defp calculate_complex([["forward", units] | rest], horizontal, vertical, aim),
    do: calculate_complex(rest, horizontal + units, vertical + units * aim, aim)

  defp calculate_complex([["up", units] | rest], horizontal, vertical, aim),
    do: calculate_complex(rest, horizontal, vertical, aim - units)

  defp calculate_complex([["down", units] | rest], horizontal, vertical, aim),
    do: calculate_complex(rest, horizontal, vertical, aim + units)
end
