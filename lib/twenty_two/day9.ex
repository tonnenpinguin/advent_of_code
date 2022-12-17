defmodule Aoc.TwentyTwo.Day9 do
  @input File.read!(Path.join(__DIR__, "inputs/day9.txt"))

  defmodule State do
    defstruct rope: [], visited: MapSet.new()

    def new(rope_length) do
      %__MODULE__{rope: for(_ <- 1..rope_length, do: {0, 0})}
    end
  end

  @doc """
  ## Examples

    iex> #{__MODULE__}.part1(~s(R 4\\nU 4\\nL 3\\nD 1\\nR 4\\nD 1\\nL 5\\nR 2\\n))
    13

  """
  def part1(input \\ @input) do
    input
    |> simulate(2)
    |> get_number_of_visited_fields()
  end

  defp get_number_of_visited_fields(%State{visited: visited}),
    do: MapSet.size(visited)

  @doc """

  ## Examples

    iex> #{__MODULE__}.part2(~s(R 5\\nU 8\\nL 8\\nD 3\\nR 17\\nD 10\\nL 25\\nU 20\\n))
    36

  """
  def part2(input \\ @input) do
    input
    |> simulate(10)
    |> get_number_of_visited_fields()
  end

  def parse_motion(<<dir, " ", steps::binary>>), do: {[dir], String.to_integer(steps)}

  def adjust({head_x, head_y} = head, {tail_x, tail_y} = tail)
      when abs(head_x - tail_x) > 1 or abs(head_y - tail_y) > 1,
      do: clamp_adjust(head, tail)

  def adjust(_, tail), do: tail

  def clamp_adjust({hx, hy}, {tx, ty}), do: {clamp_adjust(hx, tx), clamp_adjust(hy, ty)}
  def clamp_adjust(h, t), do: t + min(max(h - t, -1), 1)

  def update_rope([head, last]), do: [head, adjust(head, last)]
  def update_rope([head, next | tail]), do: [head | update_rope([adjust(head, next) | tail])]

  def execute_motion({_, 0}, state), do: state

  def execute_motion({dir, dist}, %State{rope: [{x, y} | tail], visited: visited} = state) do
    %{^dir => {mx, my}} = %{'R' => {1, 0}, 'L' => {-1, 0}, 'U' => {0, 1}, 'D' => {0, -1}}
    new_head = {x + mx, y + my}
    rope = update_rope([new_head | tail])
    state = %{state | rope: rope, visited: MapSet.put(visited, List.last(rope))}
    execute_motion({dir, dist - 1}, state)
  end

  def simulate(input, rope_len) do
    input
    |> parse_input()
    |> Enum.reduce(State.new(rope_len), &execute_motion/2)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_motion/1)
  end
end
