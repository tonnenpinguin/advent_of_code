defmodule Aoc.TwentyTwo.Day7 do
  @input File.read!(Path.join(__DIR__, "inputs/day7.txt"))

  defmodule State do
    defstruct current_dir: [], tree: %{}
  end

  defmodule Item do
    defstruct [:name, :size]
  end

  @doc """
  ## Examples

    iex> #{__MODULE__}.part1(~s($ cd /\\n$ ls\\ndir a\\n14848514 b.txt\\n8504156 c.dat\\ndir d\\n$ cd a\\n$ ls\\ndir e\\n29116 f\\n2557 g\\n62596 h.lst\\n$ cd e\\n$ ls\\n584 i\\n$ cd ..\\n$ cd ..\\n$ cd d\\n$ ls\\n4060174 j\\n8033020 d.log\\n5626152 d.ext\\n7214296 k))
    95437

  """
  def part1(input \\ @input) do
    input
    |> parse_input()
    |> build_tree()
    |> find_dirs(&Kernel.<(&1, 100_000))
    |> Enum.sum()
  end

  defp parse_input(input) do
    input
    |> String.split("$ ")
    |> Enum.drop(1)
    |> Enum.map(fn command -> command |> String.split("\n") |> Enum.reject(&Kernel.==(&1, "")) end)
  end

  defp build_tree(input) do
    input
    |> Enum.reduce(%State{}, fn command, state ->
      evaluate_command(command, state)
    end)
    |> Map.get(:tree)
  end

  defp find_dirs(tree, check_fn) do
    Enum.reduce(tree, [], fn
      {_name, content}, acc when is_map(content) ->
        acc
        |> maybe_add_dir(content, check_fn)
        |> Kernel.++(find_dirs(content, check_fn))

      {_name, _size}, acc ->
        acc
    end)
  end

  defp maybe_add_dir(acc, dir_content, check_fn) do
    dir_size = calculate_dir_size(dir_content)

    if check_fn.(dir_size) do
      acc ++ [dir_size]
    else
      acc
    end
  end

  defp calculate_dir_size(items) do
    Enum.reduce(items, 0, fn
      {_item_name, content}, current_total when is_map(content) ->
        calculate_dir_size(content) + current_total

      {_item_name, size}, current_total ->
        size + current_total
    end)
  end

  defp evaluate_command(["cd /"], %State{} = state) do
    %{state | current_dir: []}
  end

  defp evaluate_command(["cd .."], %State{} = state) do
    %{state | current_dir: Enum.drop(state.current_dir, -1)}
  end

  defp evaluate_command([<<"cd ", dir_name::binary>>], %State{} = state) do
    %{state | current_dir: state.current_dir ++ [dir_name]}
  end

  defp evaluate_command(["ls" | output], %State{} = state) do
    update_state(state, fn dir_content ->
      Enum.reduce(output, dir_content, fn item, dir_content ->
        {name, item_content} = evaluate_item(item)
        Map.put(dir_content, name, item_content)
      end)
    end)
  end

  defp evaluate_item(<<"dir ", name::binary>>) do
    {name, %{}}
  end

  defp evaluate_item(item) do
    [size_str, name] = String.split(item)
    {name, String.to_integer(size_str)}
  end

  defp update_state(%State{current_dir: []} = state, update_fn) do
    %{state | tree: Map.merge(state.tree, update_fn.(%{}))}
  end

  defp update_state(%State{} = state, update_fn) do
    %{state | tree: update_in(state.tree, state.current_dir, update_fn)}
  end

  @doc """
  ## Examples

    iex> #{__MODULE__}.part2(~s($ cd /\\n$ ls\\ndir a\\n14848514 b.txt\\n8504156 c.dat\\ndir d\\n$ cd a\\n$ ls\\ndir e\\n29116 f\\n2557 g\\n62596 h.lst\\n$ cd e\\n$ ls\\n584 i\\n$ cd ..\\n$ cd ..\\n$ cd d\\n$ ls\\n4060174 j\\n8033020 d.log\\n5626152 d.ext\\n7214296 k))
    24933642

  """
  def part2(input \\ @input) do
    tree =
      input
      |> parse_input()
      |> build_tree()

    total_size = calculate_dir_size(tree)
    currently_free_space = 70_000_000 - total_size
    required_free_space = 30_000_000 - currently_free_space

    tree
    |> find_dirs(&Kernel.>=(&1, required_free_space))
    |> Enum.min()
  end
end
