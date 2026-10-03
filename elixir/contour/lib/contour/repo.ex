defmodule Contour.Repo do
  use AshPostgres.Repo, otp_app: :contour
  def installed_extensions, do: ["ash-functions"]
  def min_pg_version, do: %Version{major: 18, minor: 0, patch: 0}
end
