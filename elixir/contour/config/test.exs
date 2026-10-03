import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :contour, Contour.Repo,
  username: System.get_env("DATABASE_USER", "postgres"),
  password: System.get_env("DATABASE_PASSWORD", "postgres"),
  hostname: System.get_env("DATABASE_HOST", "127.0.0.1"),
  port: String.to_integer(System.get_env("DATABASE_PORT", "55432")),
  database: "contour_test#{System.get_env("MIX_TEST_PARTITION")}",
  socket_dir: System.get_env("DATABASE_SOCKET_DIR"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :contour, ContourWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "phSvmL+74N3ya9CEa8cj17NRuhEyO7Nk1W1RDTzyUO+3pAOtW6duLkguNauRu357",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :contour, Oban,
  testing: :manual,
  queues: [maintenance: 2],
  plugins: [{Oban.Plugins.Cron, crontab: []}]
