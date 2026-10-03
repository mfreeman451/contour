defmodule Contour.Release do
  @moduledoc "Release migration entry point; executed once by the ArgoCD migration Job."
  def migrate do
    Application.load(:contour)

    for repo <- Application.fetch_env!(:contour, :ecto_repos) do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end
end
