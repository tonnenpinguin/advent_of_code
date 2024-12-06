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
      41
  """
  def p1(input) do
    map = parse(input)

    [start] = find_starting_position(map)

    steps = do_move(map, {start, :up}, MapSet.new())

    steps
    |> Enum.map(fn {pos, _dir} -> pos end)
    |> Enum.uniq()
    |> Enum.count()
  end

  defp do_move(map, {current, prev_dir}, steps) do
    {pos, _dir} = next = next_position(map, current, prev_dir)

    cond do
      MapSet.member?(steps, next) ->
        # We've turned here before
        nil

      exceeds_bounds?(map, pos) ->
        steps

      true ->
        do_move(map, next, MapSet.put(steps, next))
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

  defp next_position(map, current_position, dir) do
    potential_next = step(current_position, dir)

    if blocked?(map, potential_next) do
      dir = rotate(dir)
      {current_position, dir}
    else
      {potential_next, dir}
    end
  end

  defp exceeds_bounds?(map, {next_x, next_y}) do
    max = Arrays.size(map)

    next_x < 0 || next_y < 0 || next_x >= max || next_y >= max
  end

  defp find_starting_position(map) do
    for {row, x} <- Enum.with_index(map),
        {field, y} <- Enum.with_index(row),
        field == "^",
        do: {x, y}
  end

  @doc """
  1659 is too low
  1667 is too low
  1728 is incorrect
  1729 is correct...

  This solution still has a bug that I can't figure out and returns 1732

      iex> p2(example_string())
  """
  def p2(input) do
    map = parse(input)

    [start] = find_starting_position(map)

    do_move(map, {start, :up}, MapSet.new())
    |> Enum.map(fn {pos, _dir} -> pos end)
    |> Enum.uniq()
    # |> Enum.reject(&(&1 == start))
    |> Enum.map(fn {x, y} -> put_in(map[x][y], "#") end)
    |> Enum.map(fn scenario ->
      Task.async(fn ->
        do_move(scenario, {start, :up}, MapSet.new())
      end)
    end)
    |> Task.await_many(:infinity)
    |> Enum.filter(&is_nil/1)
    |> Enum.count()
  end

  defp print(map) do
    map
    |> Enum.map(fn line ->
      Enum.map(line, & &1)
      |> Enum.join()
      |> IO.puts()
    end)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&(&1 |> String.split("", trim: true) |> Arrays.new()))
    |> Arrays.new()
  end
end
