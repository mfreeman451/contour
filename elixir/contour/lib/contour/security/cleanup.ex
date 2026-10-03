defmodule Contour.Security.Cleanup do
  @moduledoc "AshOban maintenance action. Bounded batches; storage errors retry through Oban."
  use Ash.Resource.Actions.Implementation
  @impl true
  def run(_input, _opts, _context) do
    Enum.reduce_while(
      [
        {"sessions", "expires_at < now()"},
        {"oidc_attempts", "expires_at < now()"},
        {"rate_limit_buckets", "expires_at < extract(epoch FROM now())"}
      ],
      :ok,
      fn {table, condition}, :ok ->
        case Contour.Repo.query(
               "DELETE FROM #{table} WHERE ctid IN (SELECT ctid FROM #{table} WHERE #{condition} LIMIT 10000)"
             ) do
          {:ok, _} -> {:cont, :ok}
          {:error, error} -> {:halt, {:error, error}}
        end
      end
    )
  end
end
