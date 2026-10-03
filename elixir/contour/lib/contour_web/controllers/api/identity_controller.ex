defmodule ContourWeb.API.IdentityController do
  use ContourWeb, :controller

  def show(conn, _params) do
    user = conn.assigns.current_scope.user
    json(conn, %{data: %{id: user.id, display_name: user.display_name, email: user.email}})
  end

  def delete(conn, _params) do
    :ok = Contour.Accounts.revoke_session(conn.assigns.current_scope)
    send_resp(conn, 204, "")
  end
end
