defmodule ContourWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller
  alias Contour.Accounts
  alias Contour.Accounts.Scope

  def fetch_scope(conn, _opts) do
    assign(conn, :current_scope, Accounts.scope_for_token(get_session(conn, :session_token)))
  end

  def require_user(%{assigns: %{current_scope: %Scope{}}} = conn, _opts), do: conn
  def require_user(conn, _opts), do: conn |> redirect(to: "/login") |> halt()

  def api_scope(conn, _opts),
    do: assign(conn, :current_scope, Guardian.Plug.current_resource(conn))

  def secure_transport(conn, _opts) do
    if Application.fetch_env!(:contour, :secure_cookies) do
      host = ContourWeb.Endpoint.config(:url)[:host]
      Plug.SSL.call(conn, Plug.SSL.init(host: host, rewrite_on: [:x_forwarded_proto]))
    else
      conn
    end
  end

  def security_headers(conn, _opts) do
    put_secure_browser_headers(conn, %{
      "content-security-policy" =>
        "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'",
      "referrer-policy" => "same-origin",
      "permissions-policy" => "camera=(), microphone=(), geolocation=()"
    })
  end

  def on_mount(:required, _params, session, socket) do
    case Accounts.scope_for_token(session["session_token"]) do
      %Scope{} = scope ->
        if Phoenix.LiveView.connected?(socket) do
          Phoenix.PubSub.subscribe(Contour.PubSub, "sessions:#{scope.session_id}")
          Process.send_after(self(), :reauthorize, 60_000)
        end

        socket =
          socket
          |> Phoenix.Component.assign(:current_scope, scope)
          |> Phoenix.LiveView.attach_hook(:session_authorization, :handle_info, &handle_auth/2)

        {:cont, socket}

      nil ->
        {:halt, Phoenix.LiveView.redirect(socket, to: "/login")}
    end
  end

  defp handle_auth(:revoked, socket),
    do: {:halt, Phoenix.LiveView.redirect(socket, to: "/login")}

  defp handle_auth(:reauthorize, socket) do
    scope = socket.assigns.current_scope

    case Accounts.scope_for_session(scope.session_id, scope.user.id) do
      nil ->
        {:halt, Phoenix.LiveView.redirect(socket, to: "/login")}

      current ->
        Process.send_after(self(), :reauthorize, 60_000)
        {:halt, Phoenix.Component.assign(socket, :current_scope, current)}
    end
  end

  defp handle_auth(_message, socket), do: {:cont, socket}
end
