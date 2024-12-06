import AOC

aoc 2024, 6 do
  @moduledoc """
  https://adventofcode.com/2024/day/6

  Coordinate system:
  |- y
  x

  {x, y}
  """

  @doc """
      iex> p1(example_string())
  """
  def p1(input) do
    map = parse(input)

    [start] = find_starting_position(map)

    steps = do_move(map, :up, [start], MapSet.new())

    Enum.uniq(steps)
    |> Enum.count()
  end

  defp do_move(map, prev_dir, steps, turns) do
    current = List.first(steps)

    {pos, dir, turns, looped?} = next_position(map, current, prev_dir, turns)

    cond do
      looped? ->
        # We've turned here before
        nil

      exceeds_bounds?(map, pos) ->
        steps

      true ->
        do_move(map, dir, [pos | steps], turns)
    end
  end

  defp blocked?(map, {x, y}) do
    map[x][y] == "#"
  end

  defp rotate(dir) do
    case dir do
      :up -> :right
      :right -> :down
      :down -> :left
      :left -> :up
    end
  end

  defp step({x, y}, dir) do
    case dir do
      :up -> {x - 1, y}
      :right -> {x, y + 1}
      :down -> {x + 1, y}
      :left -> {x, y - 1}
    end
  end

  defp next_position(map, current_position, dir, turns) do
    potential_next = step(current_position, dir)

    if blocked?(map, potential_next) do
      dir = rotate(dir)
      turn = {current_position, dir}

      {step(current_position, dir), dir, MapSet.put(turns, turn), MapSet.member?(turns, turn)}
    else
      {potential_next, dir, turns, false}
    end
  end

  defp exceeds_bounds?(map, {next_x, next_y}) do
    max = Arrays.size(map)

    next_x < 0 || next_y < 0 || next_x >= max || next_y >= max
  end

  defp find_starting_position(map) do
    for {row, idx_x} <- Enum.with_index(map),
        {field, idx_y} <- Enum.with_index(row),
        field == "^",
        do: {idx_x, idx_y}
  end

  @doc """
  1659 is too low
  1667 is too low

      iex> p2(example_string())
  """
  def p2(input) do
    map = parse(input)

    [start] = find_starting_position(map)

    # steps = do_move(map, :up, [start], MapSet.new()) |> Enum.drop(-1)

    range = 0..(Arrays.size(map) - 1)

    for x <- range, y <- range, map[x][y] != "^" do
      put_in(map[x][y], "#")
    end
    # steps
    # |> Enum.uniq()
    # |> Enum.map(fn {x, y} -> put_in(map[x][y], "#") end)
    |> Enum.map(fn scenario ->
      Task.async(fn ->
        do_move(scenario, :up, [start], MapSet.new())
      end)
    end)
    |> Task.await_many(10)
    |> Enum.filter(&is_nil/1)
    |> Enum.count()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&(&1 |> String.split("", trim: true) |> Arrays.new()))
    |> Arrays.new()
  end
end
