import AOC

aoc 2024, 4 do
  @moduledoc """
  https://adventofcode.com/2024/day/4
  """

  @doc """
      iex> p1(example_string())
      18

      iex> p1(input_string())
      2462
  """
  def p1(input) do
    input = parse(input)

    num_rows = Arrays.size(input)
    num_cols = Arrays.size(input[0])

    for x <- 0..(num_rows - 1), y <- 0..(num_cols - 1) do
      xmas(input, x, y)
    end
    |> Enum.sum()
  end

  defp xmas(input, row_index, col_index) do
    for x <- -1..1, y <- -1..1, x != 0 or y != 0 do
      do_xmas(input, fn i -> row_index + i * x end, fn i -> col_index + i * y end)
    end
    |> Enum.sum()
  end

  defp do_xmas(input, row_fn, col_fn) do
    if row_fn.(3) >= 0 && col_fn.(3) >= 0 &&
         input[row_fn.(0)][col_fn.(0)] == "X" &&
         input[row_fn.(1)][col_fn.(1)] == "M" &&
         input[row_fn.(2)][col_fn.(2)] == "A" &&
         input[row_fn.(3)][col_fn.(3)] == "S" do
      1
    else
      0
    end
  end

  @doc """
      iex> p2(example_string())
      9

      iex> p2(input_string())
      1877
  """
  def p2(input) do
    input = parse(input)

    num_rows = Arrays.size(input)
    num_cols = Arrays.size(input[0])

    for x <- 0..(num_rows - 1), y <- 0..(num_cols - 1) do
      mas(input, x, y)
    end
    |> Enum.flat_map(fn i -> Enum.reject(i, &is_nil/1) end)
    |> Enum.frequencies_by(&Map.take(&1, [:col, :row]))
    |> Enum.filter(fn {_, count} -> count == 2 end)
    |> Enum.count()
  end

  defp mas(input, row_index, col_index) do
    for x <- -1..1//2, y <- -1..1//2 do
      do_mas(input, fn i -> row_index + i * x end, fn i -> col_index + i * y end)
    end
  end

  defp do_mas(input, row_fn, col_fn) do
    if row_fn.(2) >= 0 && col_fn.(2) >= 0 &&
         input[row_fn.(0)][col_fn.(0)] == "M" &&
         input[row_fn.(1)][col_fn.(1)] == "A" &&
         input[row_fn.(2)][col_fn.(2)] == "S" do
      %{row: row_fn.(1), col: col_fn.(1)}
    end
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      row
      |> String.split("", trim: true)
      |> Arrays.new()
    end)
    |> Arrays.new()
  end
end
