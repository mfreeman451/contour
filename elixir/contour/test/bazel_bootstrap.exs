# Plain `elixir -r` needs the configuration and startup that Mix normally supplies.
for path <- :code.get_path(), file <- Path.wildcard(Path.join(List.to_string(path), "*.app")) do
  file |> Path.basename(".app") |> String.to_atom() |> Application.load()
end

Config.Reader.read!("config/config.exs", env: :test, target: :host) |> Application.put_all_env()
{:ok, _} = Application.ensure_all_started(:ecto_sql)

{:ok, _, _} =
  Ecto.Migrator.with_repo(Contour.Repo, fn repo ->
    Ecto.Migrator.run(repo, "priv/repo/migrations", :up, all: true, log: false)
  end)

{:ok, _} = Application.ensure_all_started(:contour)
