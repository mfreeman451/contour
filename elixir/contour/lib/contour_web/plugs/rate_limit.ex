defmodule ContourWeb.Plugs.RateLimit do
  import Plug.Conn
  def init(opts), do: opts

  def call(conn, opts) do
    key =
      case Keyword.fetch!(opts, :by) do
        :ip -> "#{opts[:bucket]}:ip:#{:inet.ntoa(conn.remote_ip)}"
        :user -> "#{opts[:bucket]}:user:#{conn.assigns.current_scope.user.id}"
      end

    case Contour.Security.RateLimiter.check(key, Keyword.fetch!(opts, :limit)) do
      :ok -> conn
      {:error, {:limited, retry_after}} -> reject(conn, 429, "rate_limited", retry_after)
      {:error, :unavailable} -> reject(conn, 503, "temporarily_unavailable", 5)
    end
  end

  defp reject(conn, status, error, retry_after) do
    conn
    |> put_resp_header("retry-after", to_string(retry_after))
    |> put_resp_content_type("application/json")
    |> send_resp(status, JSON.encode!(%{error: error}))
    |> halt()
  end
end
