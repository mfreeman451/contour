defmodule ContourWeb.Auth.ErrorHandler do
  import Plug.Conn

  def auth_error(conn, _error, _opts) do
    conn
    |> put_resp_header("www-authenticate", "Bearer")
    |> put_resp_content_type("application/json")
    |> send_resp(401, JSON.encode!(%{error: "unauthorized"}))
    |> halt()
  end
end
