defmodule ContourWeb.Health do
  @moduledoc "Internal probes: liveness is independent of PostgreSQL; readiness requires it."
  import Plug.Conn
  def init(opts), do: opts

  def call(%{request_path: "/health/live"} = conn, _opts),
    do: conn |> send_resp(200, "ok") |> halt()

  def call(%{request_path: "/health/ready"} = conn, _opts) do
    status =
      case Contour.Repo.query("SELECT 1", [], timeout: 1_000) do
        {:ok, _} -> 200
        {:error, _} -> 503
      end

    conn |> send_resp(status, if(status == 200, do: "ready", else: "unavailable")) |> halt()
  rescue
    DBConnection.ConnectionError -> conn |> send_resp(503, "unavailable") |> halt()
  end

  def call(conn, _opts), do: conn
end
