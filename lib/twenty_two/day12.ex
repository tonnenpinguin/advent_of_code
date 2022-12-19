defmodule Aoc.TwentyTwo.Day12 do
  defp get_input do
    File.read!(Path.join(__DIR__, "inputs/day12.txt"))
  end

  defmodule QueueMapSet do
    defstruct items: MapSet.new()

    def new do
      %__MODULE__{}
    end

    def empty?(%__MODULE__{items: items}), do: MapSet.size(items) == 0

    def push(%__MODULE__{} = queue, item) do
      %{queue | items: MapSet.put(queue.items, item)}
    end

    def pop(%__MODULE__{items: items} = queue) do
      case MapSet.to_list(items) do
        [] -> {nil, queue}
        [head | _] -> {head, %{queue | items: MapSet.delete(items, head)}}
      end
    end
  end

  # queue implementation with List
  defmodule QueueList do
    defstruct items: []

    def new do
      %__MODULE__{}
    end

    def empty?(%__MODULE__{items: items}), do: length(items) == 0

    def push(%__MODULE__{} = queue, item) do
      if is_nil(Enum.find_index(queue.items, fn x -> x == item end)) do
        %{queue | items: queue.items ++ [item]}
      else
        queue
      end
    end

    def pop(%__MODULE__{items: items} = queue) do
      case items do
        [] -> {nil, queue}
        [head | tail] -> {head, %{queue | items: tail}}
      end
    end
  end

  defmodule QueueList2 do
    defstruct items: []

    def new do
      %__MODULE__{}
    end

    def empty?(%__MODULE__{items: items}), do: length(items) == 0

    def push(%__MODULE__{} = queue, item, current) do
      if is_nil(Enum.find_index(queue.items, &Kernel.==(&1, {item, current}))) do
        %{queue | items: queue.items ++ [{item, current}]}
      else
        # IO.inspect(%{items: queue.items, new: item, current: current})
        queue
      end
    end

    def pop(%__MODULE__{items: items} = queue) do
      case items do
        [] -> {nil, queue}
        [{head, _current} | tail] -> {head, %{queue | items: tail}}
      end
    end
  end

  alias QueueList2, as: Queue

  @doc """
  ## Examples

    iex> #{__MODULE__}.part1(~s(Sabqponm\\nabcryxxl\\naccszExk\\nacctuvwj\\nabdefghi))
    31

  """
  def part1(input \\ get_input()) do
    map = parse_input(input)

    start = find(map, ?S)
    goal = find(map, ?E)

    shortest_path(map, start, goal)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
    |> Nx.tensor()
  end

  # Find shortest path from ?S to ?E using DFS
  # You can only move to neighbors that are a maximum of 1 higher or lower
  # Start and end do not have this constraint
  def shortest_path(map, start, goal) do
    queue =
      Queue.new()
      |> Queue.push({start, 0}, start)

    visited = MapSet.new([])

    # Nx.to_heatmap(map) |> IO.inspect()
    shortest_path(map, queue, visited, goal)
  end

  def shortest_path(map, queue, visited, goal) do
    case Queue.pop(queue) do
      {nil, _queue} ->
        IO.puts("No path found")
        print_visited(map, visited)

        nil

      {{current, distance}, queue} ->
        if current == goal do
          print_visited(map, visited)
          distance
        else
          visited = MapSet.put(visited, current)

          queue = add_neighbors(map, queue, visited, current, distance)
          shortest_path(map, queue, visited, goal)
        end
    end
  end

  defp print_visited(map, visited) do
    # MapSet to Nx.Tensor
    {max_x, max_y} = Nx.shape(map)

    # Enum.reduce(visited, Nx.tensor([[0..max_x], [0..max_y]]), fn {x, y}, tensor ->
    #   Nx.put_slice(tensor, [x, y], Nx.tensor(1))
    # end)
    # |> IO.inspect()

    # Set all items in map that are not in visited to 0

    # Nx.where(map, visited, 1, 0)
    # |> Nx.to_heatmap()
    # |> IO.inspect()
    IO.puts("")

    # print map
    for x <- 0..(max_x - 1) do
      for y <- 0..(max_y - 1) do
        if MapSet.member?(visited, {x, y}) do
          (map[x][y] |> Nx.to_number()) - 32
        else
          map[x][y]
          |> Nx.to_number()
        end
      end

      # |> IO.inspect()
    end
  end

  def add_neighbors(map, queue, visited, current, distance) do
    Enum.reduce(neighbors(map, current), queue, fn {x, y}, queue ->
      if MapSet.member?(visited, {x, y}) do
        queue
      else
        Queue.push(queue, {{x, y}, distance + 1}, current)
      end
    end)
  end

  def neighbors(map, {x, y}) do
    {max_x, max_y} = Nx.shape(map)
    current_value = get_value(map[x][y])

    for {x, y} <- [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}] do
      cond do
        x < 0 ->
          nil

        y < 0 ->
          nil

        x >= max_x ->
          nil

        y >= max_y ->
          nil

        get_value(map[x][y]) - current_value > 1 ->
          nil

        true ->
          {x, y}
      end
    end
    |> Enum.reject(&is_nil/1)
  end

  defp get_value(val) do
    case Nx.to_number(val) do
      ?S -> ?a - 1
      ?E -> ?z + 1
      val -> val
    end
  end

  # find coordinates of a value in a Nx.Tensor
  def find(tensor, value) do
    idx =
      tensor
      |> Nx.to_flat_list()
      |> Enum.find_index(fn x -> x == value end)

    {_x, y} = Nx.shape(tensor)
    {trunc(idx / y), rem(idx, y)}
  end

  # find all coordinates of a value in a Nx.Tensor
  def find_all(tensor, value) do
    tensor
    |> Nx.to_flat_list()
    |> Enum.with_index()
    |> Enum.filter(fn {x, _idx} -> x == value end)
    |> Enum.map(fn {_x, idx} ->
      {_x, y} = Nx.shape(tensor)
      {trunc(idx / y), rem(idx, y)}
    end)
  end

  @doc """
  ## Examples

    iex> #{__MODULE__}.part2(~s(Sabqponm\\nabcryxxl\\naccszExk\\nacctuvwj\\nabdefghi))
    29

  """
  def part2(input \\ get_input()) do
    map = parse_input(input)

    potential_starts = find_all(map, ?a) |> length() |> IO.inspect()
    goal = find(map, ?E)

    Enum.map(potential_starts, fn start ->
      IO.inspect(start)
      shortest_path(map, start, goal)
    end)
    |> Enum.min()
  end
end
