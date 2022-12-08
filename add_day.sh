#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage $0 dayNr"
    exit -1
fi

day=$1
year="twenty_two"
yearAtom="TwentyTwo"

session=$(cat .session)
wget "https://adventofcode.com/2022/day/$day/input" -O "lib/$year/inputs/day$day.txt" --header "Cookie: session=$session"

cat << EOF > "lib/$year/day$day.ex"
defmodule Aoc.$yearAtom.Day$day do
  @input File.read!(Path.join(__DIR__, "inputs/day$day.txt"))

  @doc """
  ## Examples

    iex> #{__MODULE__}.part1(~s(1000\\\\n2000\\\\n3000))
    24000

  """
  def part1(input \\\\ @input) do
    input
  end
end
EOF

cat << EOF > "test/$year/day${day}_test.exs"
defmodule Aoc.$yearAtom.Day${day}Test do
  use ExUnit.Case
  doctest Aoc.$yearAtom.Day$day
end
EOF
