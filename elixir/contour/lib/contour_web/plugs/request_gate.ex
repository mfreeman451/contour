defmodule ContourWeb.Plugs.RequestGate do
  @moduledoc "Apply ingress quotas before parsing API/auth bodies. Forwarding headers have explicit trust."
  def init(opts), do: opts

  def call(conn, _opts) do
    proxies = Application.fetch_env!(:contour, :trusted_proxies)

    conn =
      if proxies == [] do
        conn
      else
        RemoteIp.call(conn, RemoteIp.init(headers: ["x-forwarded-for"], proxies: proxies))
      end

    cond do
      String.starts_with?(conn.request_path, "/api/") ->
        ContourWeb.Plugs.RateLimit.call(conn, by: :ip, bucket: "api", limit: 300)

      String.starts_with?(conn.request_path, "/auth/") ->
        ContourWeb.Plugs.RateLimit.call(conn, by: :ip, bucket: "auth", limit: 20)

      true ->
        conn
    end
  end
end
