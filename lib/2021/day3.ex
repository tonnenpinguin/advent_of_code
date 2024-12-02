defmodule Aoc.TwentyOne.Day3 do
  import Bitwise
  @input File.read!(Path.join(__DIR__, "inputs/day3.txt"))
  @doc """
  ## Examples

      iex> #{__MODULE__}.part1(~s(00100\\n11110\\n10110\\n10111\\n10101\\n01111\\n00111\\n11100\\n10000\\n11001\\n00010\\n01010))
      198
  """
  def part1(input \\ @input) do
    analysed_input =
      input
      |> parse()
      |> analyse()

    gamma_rate = to_gamma_rate(analysed_input)
    epsilon_rate = to_epsilon_rate(analysed_input)
    gamma_rate * epsilon_rate
  end

  defp parse(input) do
    input
    |> String.split("\n")
  end

  defp analyse(input) do
    initial_result = seed_result(input)
    analyse(input, initial_result)
  end

  defp analyse([], result), do: result
  defp analyse([bitmask | rest], result), do: analyse(rest, merge_result(bitmask, result))

  defp seed_result(input) do
    input
    |> Enum.at(0, [])
    |> to_list()
    |> Enum.map(fn _ -> 0 end)
  end

  defp to_list(list) when is_list(list), do: list
  defp to_list(bin) when is_binary(bin), do: :binary.bin_to_list(bin)

  defp merge_result(_bitmask, _prev_result, end_result \\ [])

  defp merge_result(<<>>, [], end_result), do: end_result

  defp merge_result(<<bit, remaining_bitmask::binary>>, [count | remaining_count], end_result) do
    merge_result(
      remaining_bitmask,
      remaining_count,
      end_result ++ [if(bit == ?1, do: count + 1, else: count - 1)]
    )
  end

  defp to_gamma_rate(input), do: to_integer(input, fn bit -> if bit > 0, do: 1, else: 0 end)
  defp to_epsilon_rate(input), do: to_integer(input, fn bit -> if bit > 0, do: 0, else: 1 end)

  defp to_integer(input, value_fn, result \\ 0)
  defp to_integer([], _value_fn, result), do: result

  defp to_integer([bit | remaining_bits], value_fn, results),
    do: to_integer(remaining_bits, value_fn, results <<< 1 ||| value_fn.(bit))

  @doc """
  ## Examples

      iex> #{__MODULE__}.part2(~s(00100\\n11110\\n10110\\n10111\\n10101\\n01111\\n00111\\n11100\\n10000\\n11001\\n00010\\n01010))
      230
  """
  def part2(input \\ @input) do
    parsed_input = parse(input)

    oxygen_rate =
      find_rate(
        parsed_input,
        &to_oxygen_rating_bitmask/1
      )
      |> to_binary_list()
      |> to_gamma_rate()

    co_2_scrubber_rate =
      find_rate(
        parsed_input,
        &to_co2_scrubber_rate/1
      )
      |> to_binary_list()
      |> to_gamma_rate()

    oxygen_rate * co_2_scrubber_rate
  end

  defp to_binary_list(input, result \\ [])
  defp to_binary_list(<<>>, result), do: result

  defp to_binary_list(<<bit, remaining_bits::binary>>, result),
    do: to_binary_list(remaining_bits, result ++ [if(bit == ?1, do: 1, else: 0)])

  defp to_oxygen_rating_bitmask(input),
    do: to_bitmask(input, fn bit -> if bit >= 0, do: 1, else: 0 end)

  defp to_co2_scrubber_rate(input),
    do: to_bitmask(input, fn bit -> if bit >= 0, do: 0, else: 1 end)

  defp to_bitmask(input, value_fn, result \\ [])
  defp to_bitmask([], _value_fn, result), do: result

  defp to_bitmask([bit | remaining_bits], value_fn, results),
    do: to_bitmask(remaining_bits, value_fn, results ++ [value_fn.(bit)])

  defp find_rate(rates, to_bitmask_fn, bitmask_index \\ 0)

  defp find_rate([], _to_bitmask_fn, _bitmask_index), do: raise("this shoudltn happen")

  defp find_rate([rate], _to_bitmask_fn, _bitmask_index), do: rate

  defp find_rate(rates, to_bitmask_fn, bitmask_index) do
    bitmask = to_bitmask_fn.(rates |> analyse())
    bit = Enum.at(bitmask, bitmask_index)

    filtered_rates =
      Enum.filter(rates, fn rate ->
        rate |> to_binary_list() |> Enum.at(bitmask_index) == bit
      end)

    find_rate(
      filtered_rates,
      to_bitmask_fn,
      bitmask_index + 1
    )
  end
end
