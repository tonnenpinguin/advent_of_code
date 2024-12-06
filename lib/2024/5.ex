import AOC

aoc 2024, 5 do
  @moduledoc """
  https://adventofcode.com/2024/day/5
  """

  @doc """
      iex> p1(example_string())
      143
  """
  def p1(input) do
    {ordering_rules, updates} = parse(input)

    prerequisites = calculate_prerequisites(ordering_rules)

    updates
    |> Enum.filter(&correctly_ordered?(&1, prerequisites))
    |> Enum.map(&get_center_element/1)
    |> Enum.sum()
  end

  @doc """
      iex> p2(example_string())
      123
  """
  def p2(input) do
    {ordering_rules, updates} = parse(input)

    prerequisites = calculate_prerequisites(ordering_rules)

    updates
    |> Enum.reject(&correctly_ordered?(&1, prerequisites))
    |> Enum.map(&fix_incorrectly_ordered_update(&1, prerequisites))
    |> Enum.map(&get_center_element/1)
    |> Enum.sum()
  end

  defp fix_incorrectly_ordered_update(update, prerequisites) do
    incorrectly_placed_idx =
      update
      |> Enum.with_index()
      |> Enum.find_index(&(not correctly_placed?(&1, update, prerequisites)))

    if is_nil(incorrectly_placed_idx) do
      update
    else
      incorrectly_placed_idx = max(incorrectly_placed_idx, 1)

      update
      |> swap(incorrectly_placed_idx, incorrectly_placed_idx - 1)
      |> fix_incorrectly_ordered_update(prerequisites)
    end
  end

  defp swap(a, i1, i2) do
    e1 = Enum.at(a, i1)
    e2 = Enum.at(a, i2)

    a
    |> List.replace_at(i1, e2)
    |> List.replace_at(i2, e1)
  end

  defp correctly_ordered?(update, prerequisites) do
    update
    |> Enum.with_index()
    |> Enum.all?(&correctly_placed?(&1, update, prerequisites))
  end

  defp correctly_placed?({page, index}, update, prerequisites) do
    visited_pages = Enum.slice(update, 0, index)

    prerequisites
    |> Map.get(page, [])
    |> Enum.any?(&Enum.member?(visited_pages, &1))
    |> Kernel.not()
  end

  defp get_center_element(line) do
    Enum.at(line, floor(length(line) / 2.0))
  end

  defp calculate_prerequisites(ordering_rules) do
    ordering_rules
    |> Enum.reduce(Map.new(), fn [first, second], acc ->
      Map.update(acc, first, [second], &Kernel.++(&1, [second]))
    end)
  end

  def parse(input) do
    [ordering_rules, updates] = String.split(input, "\n\n")

    {
      ordering_rules
      |> String.split("\n", trim: true)
      |> Enum.map(fn line -> line |> String.split("|") |> Enum.map(&String.to_integer/1) end),
      updates
      |> String.split("\n", trim: true)
      |> Enum.map(fn line -> line |> String.split(",") |> Enum.map(&String.to_integer/1) end)
    }
  end
end
