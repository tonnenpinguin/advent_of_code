import Config

config :advent_of_code_utils,
  gen_tests?: true,
  auto_compile?: true,
  session: File.read!("./.session")

config :iex, inspect: [charlists: :as_lists]
