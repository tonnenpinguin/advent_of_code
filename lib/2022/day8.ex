defmodule Aoc.TwentyTwo.Day8 do
  alias Nx.Tensor
  @input File.read!(Path.join(__DIR__, "inputs/day8.txt"))

  @doc """
  30373
  25512
  65332
  33549
  35390

  y x ->
  |
  _
  ## Examples

    iex> #{__MODULE__}.part1(~s(30373\\n25512\\n65332\\n33549\\n35390))
    21

  """
  def part1(input \\ @input) do
    map = parse_input(input)

    map
    |> set_visible_trees()
    |> count_visible_trees()
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split("")
      |> sanitize_list()
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.reject(&Enum.empty?/1)
    |> Nx.tensor()
  end

  defp set_visible_trees(%Tensor{} = map) do
    max_idx = max_idx(map)

    for x <- 0..max_idx do
      for y <- 0..max_idx do
        visible?(map, x, y)
      end
    end
  end

  defp visible?(_map, _tree_x, 0 = _tree_y), do: true
  defp visible?(_map, 0 = _tree_x, _tree_y), do: true

  defp visible?(%Tensor{} = map, tree_x, tree_y) do
    max_idx = max_idx(map)

    case {tree_x, tree_y} do
      {^max_idx, _} ->
        true

      {_, ^max_idx} ->
        true

      {x, y} ->
        target = map[x][y] |> Nx.to_number()
        row = map[x]
        column = map[[.., y]]

        all_smaller?(row[0..(y - 1)//1], target) or all_smaller?(row[(y + 1)..-1//1], target) or
          all_smaller?(column[0..(x - 1)//1], target) or
          all_smaller?(column[(x + 1)..-1//1], target)
    end
  end

  defp all_smaller?(%Tensor{} = lane, target) do
    result =
      lane
      |> Nx.to_flat_list()
      |> Enum.all?(&Kernel.<(&1, target))

    result
  end

  defp max_idx(%Tensor{shape: {len_x, _}}), do: len_x - 1

  defp sanitize_list(input), do: input |> Enum.drop(1) |> Enum.drop(-1)

  defp count_visible_trees(map) do
    Enum.reduce(
      map,
      0,
      &Enum.reduce(&1, &2, fn visible?, acc -> if visible?, do: acc + 1, else: acc end)
    )
  end

  @doc """
  30373
  25512
  65332
  33549
  35390

  y x ->
  |
  _
  ## Examples

    iex> #{__MODULE__}.part2(~s(30373\\n25512\\n65332\\n33549\\n35390))
    8

  """
  def part2(input \\ @input) do
    map = parse_input(input)

    map
    |> set_scenic_scores()
    |> find_max_scenic_score()
  end

  defp set_scenic_scores(%Tensor{} = map) do
    max_scenic_idx = max_idx(map) - 1

    for x <- 1..max_scenic_idx do
      for y <- 1..max_scenic_idx do
        get_scenic_score(map, x, y)
      end
    end
  end

  defp get_scenic_score(%Tensor{} = map, x, y) do
    target = map[x][y] |> Nx.to_number()
    row = map[x]
    column = map[[.., y]]

    count_visible_trees(row[0..(y - 1)//1] |> Nx.to_flat_list() |> Enum.reverse(), target) *
      count_visible_trees(row[(y + 1)..-1//1] |> Nx.to_flat_list(), target) *
      count_visible_trees(column[0..(x - 1)//1] |> Nx.to_flat_list() |> Enum.reverse(), target) *
      count_visible_trees(column[(x + 1)..-1//1] |> Nx.to_flat_list(), target)
  end

  defp count_visible_trees(lane, target) do
    lane
    |> count_visible_trees(target, 0)
  end

  defp count_visible_trees([], _target, count), do: count

  defp count_visible_trees([tree | _rest], target, count) when tree >= target,
    do: count + 1

  defp count_visible_trees([_tree | rest], target, count),
    do: count_visible_trees(rest, target, count + 1)

  defp find_max_scenic_score(scores) do
    scores
    |> List.flatten()
    |> Enum.max()
  end
end
