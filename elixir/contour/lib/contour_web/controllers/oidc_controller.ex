defmodule ContourWeb.OIDCController do
  use ContourWeb, :controller
  alias Contour.{Accounts, Auth.OIDC}

  def request(conn, _params) do
    if Application.get_env(:contour, :oidc) do
      case OIDC.authorize() do
        {:ok, url, challenge} ->
          conn
          |> put_resp_header("cache-control", "no-store")
          |> put_session(:oidc_challenge, challenge)
          |> redirect(external: url)

        {:error, _} ->
          failure(conn)
      end
    else
      conn |> put_status(503) |> text("Google login is not configured.")
    end
  end

  def callback(conn, params) do
    challenge = get_session(conn, :oidc_challenge)
    conn = delete_session(conn, :oidc_challenge)

    with {:ok, user} <- OIDC.exchange(challenge, params["state"], params["code"]),
         {:ok, token, _session} <- Accounts.create_session(user) do
      if conn.assigns.current_scope, do: Accounts.revoke_session(conn.assigns.current_scope)

      conn
      |> configure_session(renew: true)
      |> clear_session()
      |> put_session(:session_token, token)
      |> redirect(to: ~p"/lobby")
    else
      _ -> failure(conn)
    end
  end

  defp failure(conn) do
    conn
    |> delete_session(:oidc_challenge)
    |> put_flash(:error, "Google login failed. Please try again.")
    |> redirect(to: ~p"/login")
  end
end
