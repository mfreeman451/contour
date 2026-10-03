# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :contour,
  ecto_repos: [Contour.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true],
  ash_domains: [Contour.Accounts, Contour.Security],
  role: :all,
  cluster_enabled: false,
  membership_interval: 2_000,
  horde_crdt: [sync_interval: 200, max_sync_size: 200],
  secure_cookies: false,
  oidc: nil,
  trusted_proxies: []

config :contour, Contour.Auth.Guardian,
  issuer: "contour",
  verify_issuer: true,
  allowed_algos: ["HS256"],
  secret_key: "development-only-guardian-key-replace-in-releases-at-least-64-bytes-long"

config :phoenix, :filter_parameters, [
  "token",
  "code",
  "state",
  "nonce",
  "secret",
  "password",
  "authorization"
]

config :ash, default_string_length_count: :codepoints

config :contour, Oban,
  repo: Contour.Repo,
  queues: [maintenance: 2],
  plugins: [{Oban.Plugins.Pruner, max_age: 86_400}, {Oban.Plugins.Cron, crontab: []}]

# Configures the endpoint
config :contour, ContourWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ContourWeb.ErrorHTML, json: ContourWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Contour.PubSub,
  live_view: [signing_salt: "uCSxkDqw"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.28.2",
  contour: [
    args:
      ~w(src/app.ts --bundle --target=esnext --outdir=../elixir/contour/priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../../../web", __DIR__),
    env: %{
      "NODE_PATH" => [
        Path.expand("../deps", __DIR__),
        Path.expand("../_build/#{config_env()}", __DIR__)
      ]
    }
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.3.0",
  contour: [
    args: ~w(
      --input=../../web/styles/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, JSON

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
