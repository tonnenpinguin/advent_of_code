defmodule Aoc.TwentyTwo.Day11 do
  @input File.read!(Path.join(__DIR__, "inputs/day11.txt"))

  defmodule BasicMath do
    # From https://programming-idioms.org/idiom/75/compute-lcm/983/elixir
    def gcd(a, 0), do: a
    def gcd(0, b), do: b
    def gcd(a, b), do: gcd(b, rem(a, b))

    def lcm(0, 0), do: 0
    def lcm(a, b), do: div(a * b, gcd(a, b))
  end

  defmodule Monkey do
    defstruct [
      :monkey_idx,
      :worry_fn,
      :divisor,
      :monkey_on_true,
      :monkey_on_false,
      starting_items: [],
      inspected_item_count: 0
    ]
  end

  @doc """
  ## Examples

    iex> #{__MODULE__}.part1(~s(Monkey 0:\\n  Starting items: 79, 98\\n  Operation: new = old * 19\\n  Test: divisible by 23\\n    If true: throw to monkey 2\\n    If false: throw to monkey 3\\n\\nMonkey 1:\\n  Starting items: 54, 65, 75, 74\\n  Operation: new = old + 6\\n  Test: divisible by 19\\n    If true: throw to monkey 2\\n    If false: throw to monkey 0\\n\\nMonkey 2:\\n  Starting items: 79, 60, 97\\n  Operation: new = old * old\\n  Test: divisible by 13\\n    If true: throw to monkey 1\\n    If false: throw to monkey 3\\n\\nMonkey 3:\\n  Starting items: 74\\n  Operation: new = old + 3\\n  Test: divisible by 17\\n    If true: throw to monkey 0\\n    If false: throw to monkey 1\\n))
    10605

  """
  def part1(input \\ @input) do
    input
    |> parse_input()
    |> handle_monkeys(20, fn worry_level -> trunc(worry_level / 3) end)
    |> Enum.sort_by(fn %Monkey{inspected_item_count: items} -> items end, :desc)
    |> Enum.take(2)
    |> calculate_monkey_business()
  end

  defp parse_input(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_monkey/1)
  end

  defp calculate_monkey_business([
         %Monkey{inspected_item_count: i},
         %Monkey{inspected_item_count: j}
       ]),
       do: i * j

  defp handle_monkeys(monkeys, rounds, worry_level_fn) do
    Enum.reduce(1..rounds, monkeys, fn round, monkeys ->
      IO.puts("Round #{round}")

      Enum.reduce(0..(length(monkeys) - 1), monkeys, fn monkey_idx, monkeys ->
        %Monkey{} = monkey = Enum.at(monkeys, monkey_idx)

        Enum.reduce(monkey.starting_items, monkeys, fn worry_level_before, monkeys ->
          worry_level_after =
            worry_level_before
            |> monkey.worry_fn.()
            |> worry_level_fn.()

          throw_to_monkey =
            if rem(worry_level_after, monkey.divisor) == 0,
              do: monkey.monkey_on_true,
              else: monkey.monkey_on_false

          monkeys
          |> List.update_at(throw_to_monkey, fn %Monkey{} = m ->
            %{m | starting_items: m.starting_items ++ [worry_level_after]}
          end)
          |> List.update_at(monkey.monkey_idx, fn %Monkey{} = m ->
            %{
              m
              | inspected_item_count: m.inspected_item_count + 1,
                starting_items: Enum.drop(m.starting_items, 1)
            }
          end)
        end)
      end)
    end)
  end

  defp parse_monkey(<<"Monkey ", monkey_idx, ":\n", rest::binary>>) do
    rest
    |> String.split("\n", trim: true)
    |> Enum.reduce(%Monkey{monkey_idx: String.to_integer(<<monkey_idx>>)}, &parse_monkey/2)
  end

  defp parse_monkey(<<"  Starting items: ", items::binary>>, %Monkey{} = monkey) do
    %{monkey | starting_items: items |> String.split(", ") |> Enum.map(&String.to_integer/1)}
  end

  defp parse_monkey(<<"  Operation: new = old ", operation::binary>>, %Monkey{} = monkey) do
    %{monkey | worry_fn: parse_operation(operation)}
  end

  defp parse_monkey(<<"  Test: divisible by ", amount::binary>>, %Monkey{} = monkey) do
    %{monkey | divisor: String.to_integer(amount)}
  end

  defp parse_monkey(<<"    If true: throw to monkey ", to_monkey::binary>>, %Monkey{} = monkey) do
    %{monkey | monkey_on_true: String.to_integer(to_monkey)}
  end

  defp parse_monkey(<<"    If false: throw to monkey ", to_monkey::binary>>, %Monkey{} = monkey) do
    %{monkey | monkey_on_false: String.to_integer(to_monkey)}
  end

  defp parse_operation(<<"* old">>) do
    fn worry_level -> worry_level * worry_level end
  end

  defp parse_operation(<<"+ ", amount::binary>>) do
    fn worry_level -> worry_level + String.to_integer(amount) end
  end

  defp parse_operation(<<"* ", amount::binary>>) do
    fn worry_level -> worry_level * String.to_integer(amount) end
  end

  @doc """
  ## Examples

    iex> #{__MODULE__}.part2(~s(Monkey 0:\\n  Starting items: 79, 98\\n  Operation: new = old * 19\\n  Test: divisible by 23\\n    If true: throw to monkey 2\\n    If false: throw to monkey 3\\n\\nMonkey 1:\\n  Starting items: 54, 65, 75, 74\\n  Operation: new = old + 6\\n  Test: divisible by 19\\n    If true: throw to monkey 2\\n    If false: throw to monkey 0\\n\\nMonkey 2:\\n  Starting items: 79, 60, 97\\n  Operation: new = old * old\\n  Test: divisible by 13\\n    If true: throw to monkey 1\\n    If false: throw to monkey 3\\n\\nMonkey 3:\\n  Starting items: 74\\n  Operation: new = old + 3\\n  Test: divisible by 17\\n    If true: throw to monkey 0\\n    If false: throw to monkey 1\\n))
    2713310158

  """
  def part2(input \\ @input) do
    monkeys = parse_input(input)

    lcm_of_divisors =
      monkeys
      |> Enum.map(fn %Monkey{divisor: divisor} -> divisor end)
      |> Enum.reduce(&BasicMath.lcm/2)
      |> IO.inspect()

    worry_level_fn = fn worry_level -> rem(worry_level, lcm_of_divisors) end

    monkeys
    |> handle_monkeys(10000, worry_level_fn)
    |> Enum.sort_by(fn %Monkey{inspected_item_count: items} -> items end, :desc)
    |> Enum.take(2)
    |> calculate_monkey_business()
  end
end
