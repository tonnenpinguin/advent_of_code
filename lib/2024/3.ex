import AOC

aoc 2024, 3 do
  @moduledoc """
  https://adventofcode.com/2024/day/3
  """

  @doc """
      iex> p1(example_string())
      161
  """
  def p1(input) do
    # It seems like the goal of the program is just to multiply some numbers.
    # It does that with instructions like mul(X,Y), where X and Y are each 1-3 digit numbers.
    # For instance, mul(44,46) multiplies 44 by 46 to get a result of 2024.
    # Similarly, mul(123,4) would multiply 123 by 4.

    Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)/, input, capture: :all_but_first)
    |> Enum.map(&multiply/1)
    |> Enum.sum()
  end

  @doc """
      iex> p2("xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))")
      48
  """
  def p2(input) do
    Regex.scan(~r/(?:(?:do\(\))|(?:don't\(\)))|mul\((\d{1,3}),(\d{1,3})\)/, input)
    |> Enum.reduce({:do, 0}, fn
      ["don't()"], {_, val} ->
        {:dont, val}

      ["do()"], {_, val} ->
        {:do, val}

      [_mul, a, b], {:do, val} ->
        {:do, multiply([a, b]) + val}

      [_mul, _a, _b], {:dont, val} ->
        {:dont, val}
    end)
    |> elem(1)
  end

  defp multiply([a, b]), do: String.to_integer(a) * String.to_integer(b)
end
