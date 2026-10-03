defmodule ContourWeb.SessionController do
  use ContourWeb, :controller

  def delete(conn, _params) do
    :ok = Contour.Accounts.revoke_session(conn.assigns.current_scope)
    conn |> configure_session(drop: true) |> redirect(to: ~p"/login")
  end

  def token(conn, _params) do
    {:ok, token, claims} = Contour.Auth.Guardian.issue_api_token(conn.assigns.current_scope)

    conn
    |> put_resp_header("cache-control", "no-store")
    |> json(%{
      access_token: token,
      token_type: "Bearer",
      expires_in: claims["exp"] - claims["iat"]
    })
  end
end
