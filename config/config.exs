import Config

session =
  case File.read("./.session") do
    {:ok, session} -> session
    _ -> nil
  end

config :advent_of_code_utils,
  gen_tests?: true,
  auto_compile?: true,
  time_calls?: true,
  session: session

config :iex, inspect: [charlists: :as_lists]
