import Config

role =
  case System.get_env("CONTOUR_ROLE", "all") do
    "web" -> :web
    "core" -> :core
    "all" -> :all
    "migrate" -> :migrate
    value -> raise "Invalid CONTOUR_ROLE: #{value}"
  end

cluster_enabled = System.get_env("CLUSTER_ENABLED", "false") == "true"

config :contour,
  role: role,
  cluster_enabled: cluster_enabled,
  membership_interval:
    String.to_integer(System.get_env("CLUSTER_MEMBERSHIP_INTERVAL_MS", "2000")),
  horde_crdt: [
    sync_interval: String.to_integer(System.get_env("HORDE_SYNC_INTERVAL_MS", "200")),
    max_sync_size: String.to_integer(System.get_env("HORDE_MAX_SYNC_SIZE", "200"))
  ],
  trusted_proxies: System.get_env("TRUSTED_PROXY_CIDRS", "") |> String.split(",", trim: true)

if cluster_enabled do
  topology =
    case System.get_env("CLUSTER_DNS_NAME") do
      nil ->
        [
          strategy: Cluster.Strategy.Epmd,
          config: [
            hosts:
              System.fetch_env!("CLUSTER_NODES")
              |> String.split(",", trim: true)
              |> Enum.map(&String.to_atom/1)
          ]
        ]

      service ->
        [
          strategy: Cluster.Strategy.Kubernetes.DNS,
          config: [service: service, application_name: "contour", polling_interval: 5_000]
        ]
    end

  config :libcluster, topologies: [contour: topology]
end

if System.get_env("GOOGLE_CLIENT_ID") && role in [:web, :all] do
  config :contour, :oidc,
    client_id: System.fetch_env!("GOOGLE_CLIENT_ID"),
    client_secret: System.fetch_env!("GOOGLE_CLIENT_SECRET"),
    redirect_uri: System.fetch_env!("OIDC_REDIRECT_URI")
end

if config_env() == :prod do
  db_host = System.fetch_env!("DATABASE_HOST")

  config :contour, Contour.Repo,
    hostname: db_host,
    username: System.fetch_env!("DATABASE_USER"),
    password: System.fetch_env!("DATABASE_PASSWORD"),
    database: System.fetch_env!("DATABASE_NAME"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "10")),
    ssl: [
      verify: :verify_peer,
      cacertfile: System.fetch_env!("DATABASE_CA_FILE"),
      server_name_indication: String.to_charlist(db_host),
      customize_hostname_check: [match_fun: :public_key.pkix_verify_hostname_match_fun(:https)]
    ]

  config :contour, :health_port, String.to_integer(System.get_env("HEALTH_PORT", "4001"))

  if role in [:web, :all] do
    host = System.fetch_env!("PHX_HOST")
    secret = System.fetch_env!("SECRET_KEY_BASE")
    jwt_key = System.fetch_env!("GUARDIAN_SECRET_KEY")

    if byte_size(secret) < 64 or byte_size(jwt_key) < 64,
      do: raise("Signing keys must be at least 64 bytes")

    System.fetch_env!("GOOGLE_CLIENT_ID")
    System.fetch_env!("GOOGLE_CLIENT_SECRET")

    if System.fetch_env!("OIDC_REDIRECT_URI") != "https://#{host}/auth/google/callback",
      do: raise("OIDC_REDIRECT_URI must match PHX_HOST")

    config :contour, Contour.Auth.Guardian, secret_key: jwt_key, issuer: "https://#{host}"

    config :contour, ContourWeb.Endpoint,
      server: System.get_env("PHX_SERVER", "true") == "true",
      url: [host: host, port: 443, scheme: "https"],
      check_origin: ["https://#{host}"],
      http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT", "4000"))],
      secret_key_base: secret
  end
end
