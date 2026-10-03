defmodule ContourWeb.Router do
  use ContourWeb, :router
  import ContourWeb.Auth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ContourWeb.Layouts, :root}
    plug :secure_transport
    plug :protect_from_forgery
    plug :security_headers
    plug :fetch_scope
  end

  pipeline :required_user do
    plug :require_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :secure_transport
    plug :put_secure_browser_headers
    plug :no_store
    plug ContourWeb.Auth.APIPipeline
    plug :api_scope
    plug ContourWeb.Plugs.RateLimit, by: :user, bucket: "api", limit: 120
  end

  scope "/", ContourWeb do
    pipe_through :browser
    get "/", PageController, :home
    get "/login", PageController, :login
    get "/auth/google", OIDCController, :request
    get "/auth/google/callback", OIDCController, :callback
  end

  scope "/", ContourWeb do
    pipe_through [:browser, :required_user]
    post "/auth/logout", SessionController, :delete
    post "/auth/api-token", SessionController, :token

    live_session :required_user, on_mount: [{ContourWeb.Auth, :required}] do
      live "/lobby", LobbyLive
    end
  end

  scope "/api/v1", ContourWeb.API do
    pipe_through :api
    get "/me", IdentityController, :show
    delete "/session", IdentityController, :delete
  end

  defp no_store(conn, _opts), do: put_resp_header(conn, "cache-control", "no-store")
end
