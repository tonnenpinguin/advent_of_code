defmodule Aoc.TwentyTwo.Day10 do
  @input File.read!(Path.join(__DIR__, "inputs/day10.txt"))

  defmodule State do
    defstruct x: 1, cycle: 0, values: [], crt: []
  end

  @doc """
  ## Examples
    iex> #{__MODULE__}.part1(~s(noop\\naddx 3\\naddx -5))
    0

    iex> #{__MODULE__}.part1(~s(addx 15\\naddx -11\\naddx 6\\naddx -3\\naddx 5\\naddx -1\\naddx -8\\naddx 13\\naddx 4\\nnoop\\naddx -1\\naddx 5\\naddx -1\\naddx 5\\naddx -1\\naddx 5\\naddx -1\\naddx 5\\naddx -1\\naddx -35\\naddx 1\\naddx 24\\naddx -19\\naddx 1\\naddx 16\\naddx -11\\nnoop\\nnoop\\naddx 21\\naddx -15\\nnoop\\nnoop\\naddx -3\\naddx 9\\naddx 1\\naddx -3\\naddx 8\\naddx 1\\naddx 5\\nnoop\\nnoop\\nnoop\\nnoop\\nnoop\\naddx -36\\nnoop\\naddx 1\\naddx 7\\nnoop\\nnoop\\nnoop\\naddx 2\\naddx 6\\nnoop\\nnoop\\nnoop\\nnoop\\nnoop\\naddx 1\\nnoop\\nnoop\\naddx 7\\naddx 1\\nnoop\\naddx -13\\naddx 13\\naddx 7\\nnoop\\naddx 1\\naddx -33\\nnoop\\nnoop\\nnoop\\naddx 2\\nnoop\\nnoop\\nnoop\\naddx 8\\nnoop\\naddx -1\\naddx 2\\naddx 1\\nnoop\\naddx 17\\naddx -9\\naddx 1\\naddx 1\\naddx -3\\naddx 11\\nnoop\\nnoop\\naddx 1\\nnoop\\naddx 1\\nnoop\\nnoop\\naddx -13\\naddx -19\\naddx 1\\naddx 3\\naddx 26\\naddx -30\\naddx 12\\naddx -1\\naddx 3\\naddx 1\\nnoop\\nnoop\\nnoop\\naddx -9\\naddx 18\\naddx 1\\naddx 2\\nnoop\\nnoop\\naddx 9\\nnoop\\nnoop\\nnoop\\naddx -1\\naddx 2\\naddx -37\\naddx 1\\naddx 3\\nnoop\\naddx 15\\naddx -21\\naddx 22\\naddx -6\\naddx 1\\nnoop\\naddx 2\\naddx 1\\nnoop\\naddx -10\\nnoop\\nnoop\\naddx 20\\naddx 1\\naddx 2\\naddx 2\\naddx -6\\naddx -11\\nnoop\\nnoop\\nnoop))
    13140

  """
  def part1(input \\ @input) do
    input
    |> parse_input()
    |> Enum.reduce(%State{}, &apply_instruction/2)
    |> Map.get(:values)
    |> Enum.drop(19)
    |> Enum.take_every(40)
    |> Enum.with_index()
    |> Enum.reduce(0, fn {value, idx}, sum ->
      sum + value * (20 + idx * 40)
    end)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instruction/1)
  end

  defp parse_instruction(<<"noop">>), do: {fn reg -> reg end, 1}

  defp parse_instruction(<<"addx ", value::binary>>),
    do: {fn reg -> reg + String.to_integer(value) end, 2}

  defp apply_instruction({fun, 1}, %State{} = state) do
    update_state(state, fun.(state.x))
  end

  defp apply_instruction({fun, cycle_count}, %State{} = state) do
    apply_instruction({fun, cycle_count - 1}, update_state(state))
  end

  defp update_state(%State{} = state, x \\ nil) do
    %{
      state
      | values: state.values ++ [state.x],
        cycle: state.cycle + 1,
        x: x || state.x
    }
    |> set_crt()
  end

  defp set_crt(%State{cycle: cycle, x: x} = state) do
    position = rem(cycle, 40)
    crt = if position >= x - 1 and position <= x + 1, do: "#", else: "."

    %{state | crt: state.crt ++ [crt]}
  end

  @doc """
  ## Examples
    iex> #{__MODULE__}.part2(~s(addx 15\\naddx -11\\naddx 6\\naddx -3\\naddx 5\\naddx -1\\naddx -8\\naddx 13\\naddx 4\\nnoop\\naddx -1\\naddx 5\\naddx -1\\naddx 5\\naddx -1\\naddx 5\\naddx -1\\naddx 5\\naddx -1\\naddx -35\\naddx 1\\naddx 24\\naddx -19\\naddx 1\\naddx 16\\naddx -11\\nnoop\\nnoop\\naddx 21\\naddx -15\\nnoop\\nnoop\\naddx -3\\naddx 9\\naddx 1\\naddx -3\\naddx 8\\naddx 1\\naddx 5\\nnoop\\nnoop\\nnoop\\nnoop\\nnoop\\naddx -36\\nnoop\\naddx 1\\naddx 7\\nnoop\\nnoop\\nnoop\\naddx 2\\naddx 6\\nnoop\\nnoop\\nnoop\\nnoop\\nnoop\\naddx 1\\nnoop\\nnoop\\naddx 7\\naddx 1\\nnoop\\naddx -13\\naddx 13\\naddx 7\\nnoop\\naddx 1\\naddx -33\\nnoop\\nnoop\\nnoop\\naddx 2\\nnoop\\nnoop\\nnoop\\naddx 8\\nnoop\\naddx -1\\naddx 2\\naddx 1\\nnoop\\naddx 17\\naddx -9\\naddx 1\\naddx 1\\naddx -3\\naddx 11\\nnoop\\nnoop\\naddx 1\\nnoop\\naddx 1\\nnoop\\nnoop\\naddx -13\\naddx -19\\naddx 1\\naddx 3\\naddx 26\\naddx -30\\naddx 12\\naddx -1\\naddx 3\\naddx 1\\nnoop\\nnoop\\nnoop\\naddx -9\\naddx 18\\naddx 1\\naddx 2\\nnoop\\nnoop\\naddx 9\\nnoop\\nnoop\\nnoop\\naddx -1\\naddx 2\\naddx -37\\naddx 1\\naddx 3\\nnoop\\naddx 15\\naddx -21\\naddx 22\\naddx -6\\naddx 1\\nnoop\\naddx 2\\naddx 1\\nnoop\\naddx -10\\nnoop\\nnoop\\naddx 20\\naddx 1\\naddx 2\\naddx 2\\naddx -6\\naddx -11\\nnoop\\nnoop\\nnoop))
    ~s(#..##..##..##..##..##..##..##..##..##..#\\n##...###...###...###...###...###...###.#\\n###....####....####....####....####....#\\n####.....#####.....#####.....#####.....#\\n#####......######......######......#####\\n######.......#######.......#######......)

  """
  def part2(input \\ @input) do
    input
    |> parse_input()
    |> Enum.reduce(%State{}, &apply_instruction/2)
    |> Map.get(:crt)
    |> Enum.chunk_every(40)
    |> Enum.map(fn line -> line |> List.to_string() end)
    |> Enum.join("\n")
  end
end
