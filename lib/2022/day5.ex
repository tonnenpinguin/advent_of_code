defmodule Aoc.TwentyTwo.Day5 do
  @input File.read!(Path.join(__DIR__, "inputs/day5.txt"))

  @doc """
  ## Examples

    iex> #{__MODULE__}.part1(~s(    [D]    \\n[N] [C]    \\n[Z] [M] [P]\\n 1   2   3 \\n\\nmove 1 from 2 to 1\\nmove 3 from 1 to 3\\nmove 2 from 2 to 1\\nmove 1 from 1 to 2))
    'CMZ'

  """
  def part1(input \\ @input) do
    input
    |> parse_input()
    |> parse_stacks_map()
    |> process_instructions(&take_single_crates/2)
    |> take_top_items()
  end

  defp parse_input(input) do
    [stacks_map, instruction_lines] = String.split(input, "\n\n")
    instruction_lines = String.split(instruction_lines, "\n")

    {stacks_map, instruction_lines}
  end

  defp parse_stacks_map({stacks_map, instruction_lines}) do
    stacks =
      stacks_map
      |> String.split("\n")
      |> Enum.drop(-1)
      |> Enum.reverse()
      |> Enum.map(&parse_stack_map_line/1)
      |> to_stack()

    {stacks, instruction_lines}
  end

  defp parse_stack_map_line(line) do
    line
    |> String.to_charlist()
    |> Enum.chunk_every(4)
    |> Enum.map(&extract_crate/1)
  end

  defp extract_crate([?[, crate, ?] | _]), do: crate
  defp extract_crate(_no_match), do: nil

  defp to_stack(input) do
    input
    |> Enum.reduce(%{}, fn stack_line, acc ->
      stack_line
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {stack_item, idx}, acc ->
        Map.update(acc, idx, [stack_item], fn current_stack ->
          maybe_append_stack_item(stack_item, current_stack)
        end)
      end)
    end)
  end

  defp maybe_append_stack_item(stack_item, stack) when is_nil(stack_item), do: stack
  defp maybe_append_stack_item(stack_item, stack) when is_list(stack), do: stack ++ [stack_item]
  defp maybe_append_stack_item(stack_item, stack), do: [stack, stack_item]

  defp process_instructions({stacks, instruction_lines}, take_fn) do
    Enum.reduce(instruction_lines, stacks, fn instruction_line, stacks ->
      instruction_line
      |> parse_instruction_line()
      |> move_items(stacks, take_fn)
    end)
  end

  defp parse_instruction_line(line) do
    %{"move" => move_str, "from" => from_str, "to" => to_str} =
      Regex.named_captures(
        ~r/move (?<move>\d+) from (?<from>\d+) to (?<to>\d+)/,
        line
      )

    %{
      move: String.to_integer(move_str),
      from_idx: String.to_integer(from_str) - 1,
      to_idx: String.to_integer(to_str) - 1
    }
  end

  defp take_top_items(stacks) do
    Enum.map(stacks, fn {_idx, item} -> Enum.at(item, -1) end)
  end

  defp move_items(%{move: move, from_idx: from_idx, to_idx: to_idx}, stacks, take_fn) do
    items_to_move =
      Map.get(stacks, from_idx)
      |> take_fn.(move)

    stacks
    |> Map.update!(from_idx, &Enum.drop(&1, move * -1))
    |> Map.update!(to_idx, &Enum.concat(&1, items_to_move))
  end

  defp take_single_crates(stack, move) do
    stack
    |> Enum.take(move * -1)
    |> Enum.reverse()
  end

  defp take_multiple_crates(stack, move) do
    stack
    |> Enum.take(move * -1)
  end

  @doc """
  ## Examples

    iex> #{__MODULE__}.part2(~s(    [D]    \\n[N] [C]    \\n[Z] [M] [P]\\n 1   2   3 \\n\\nmove 1 from 2 to 1\\nmove 3 from 1 to 3\\nmove 2 from 2 to 1\\nmove 1 from 1 to 2))
    'MCD'

  """
  def part2(input \\ @input) do
    input
    |> parse_input()
    |> parse_stacks_map()
    |> process_instructions(&take_multiple_crates/2)
    |> take_top_items()
  end
end
