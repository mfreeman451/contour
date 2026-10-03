defmodule ContourWeb.PageController do
  use ContourWeb, :controller

  def home(conn, _params),
    do: redirect(conn, to: if(conn.assigns.current_scope, do: ~p"/lobby", else: ~p"/login"))

  def login(conn, _params),
    do: render(conn, :login, oidc_enabled: not is_nil(Application.get_env(:contour, :oidc)))
end
