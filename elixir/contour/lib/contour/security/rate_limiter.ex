defmodule Contour.Security.RateLimiter do
  @moduledoc "Atomic cluster-wide fixed-window quotas. Storage failure denies admission."
  alias Contour.Repo

  use Ash.Resource.Actions.Implementation

  def check(key, limit, seconds \\ 60) do
    case Contour.Security.check_quota(key, limit, seconds, actor: %Contour.Accounts.SystemActor{}) do
      {:ok, %{allowed: true}} -> :ok
      {:ok, %{allowed: false, retry_after: retry_after}} -> {:error, {:limited, retry_after}}
      {:error, _} -> {:error, :unavailable}
    end
  end

  @impl true
  def run(input, _opts, _context) do
    %{key: key, limit: limit, seconds: seconds} = input.arguments
    hashed = Contour.Accounts.digest(key)

    sql = """
    INSERT INTO rate_limit_buckets (key, "window", count, expires_at)
    VALUES ($1, floor(extract(epoch FROM clock_timestamp()) / $3::bigint)::bigint, 1,
            (floor(extract(epoch FROM clock_timestamp()) / $3::bigint)::bigint + 1) * $3::bigint)
    ON CONFLICT (key, "window") DO UPDATE SET count = rate_limit_buckets.count + 1
    WHERE rate_limit_buckets.count < $2
    RETURNING expires_at - floor(extract(epoch FROM clock_timestamp()))::bigint
    """

    case Repo.query(sql, [hashed, limit, seconds], timeout: 2_000) do
      {:ok, %{rows: [[_retry_after]]}} -> {:ok, %{allowed: true}}
      {:ok, %{rows: []}} -> {:ok, %{allowed: false, retry_after: seconds}}
      {:error, error} -> {:error, error}
    end
  rescue
    DBConnection.ConnectionError -> {:error, :unavailable}
  end
end
