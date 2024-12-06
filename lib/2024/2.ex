import AOC

aoc 2024, 2 do
  @moduledoc """
  https://adventofcode.com/2024/day/2
  """

  @doc """
      iex> p1(example_string())
      2
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.filter(&safe?/1)
    |> Enum.count()
  end

  defp safe?([a, b | _rest] = line) do
    safe?(line, b > a)
  end

  defp safe?([_], _incrementing?), do: true

  defp safe?([a, b | rest], incrementing?) do
    min = if incrementing?, do: a + 1, else: a - 3
    max = if incrementing?, do: a + 3, else: a - 1

    within_bounds? = b >= min and b <= max

    if within_bounds? do
      safe?([b | rest], incrementing?)
    else
      false
    end
  end

  @doc """
      iex> p2(example_string())
      4
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.filter(fn line ->
      if safe?(line) do
        true
      else
        Enum.any?(0..length(line), fn index ->
          line
          |> List.delete_at(index)
          |> safe?()
        end)
      end
    end)
    |> Enum.count()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(~r(\s+))
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
