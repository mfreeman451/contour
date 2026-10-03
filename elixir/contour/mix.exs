defmodule Contour.MixProject do
  use Mix.Project

  def project do
    [
      app: :contour,
      version: "0.1.0",
      elixir: "~> 1.20.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      releases: [contour: [include_erts: true]],
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Contour.Application, []},
      extra_applications: [:logger, :runtime_tools, :ssl, :public_key]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "== 1.8.15"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "== 3.14.0"},
      {:postgrex, "== 0.22.4"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "== 1.2.12"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.5.1", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:libcluster, "== 3.5.0"},
      {:horde, "== 0.10.0"},
      {:rustler, "== 0.38.0", runtime: false},
      {:oidcc, "~> 3.8"},
      {:ash, "~> 3.33.11"},
      {:simple_sat, "~> 0.1"},
      {:ash_postgres, "~> 2.13"},
      {:ash_phoenix, "~> 2.3"},
      {:ash_oban, "~> 0.9.0"},
      {:oban, "~> 2.18"},
      {:guardian, "~> 2.3"},
      {:remote_ip, "~> 1.2"},
      {:bandit, "== 1.12.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["compile", "tailwind contour", "esbuild contour"],
      "assets.deploy": [
        "tailwind contour --minify",
        "esbuild contour --minify",
        "phx.digest"
      ],
      precommit: [
        "compile --warnings-as-errors",
        "deps.unlock --unused",
        "format --check-formatted",
        "test"
      ]
    ]
  end
end
