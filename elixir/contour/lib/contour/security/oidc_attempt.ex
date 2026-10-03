defmodule Contour.Security.OIDCAttempt do
  use Ash.Resource,
    domain: Contour.Security,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "oidc_attempts"
    repo Contour.Repo
  end

  attributes do
    attribute :state_hash, :binary, primary_key?: true, allow_nil?: false, sensitive?: true
    attribute :expires_at, :utc_datetime_usec, allow_nil?: false
  end

  actions do
    defaults [:read]

    create :create do
      accept [:state_hash, :expires_at]
      primary? true
    end

    action :consume, :boolean do
      argument :state_hash, :binary, allow_nil?: false, sensitive?: true

      run fn input, _context ->
        case Contour.Repo.query(
               "DELETE FROM oidc_attempts WHERE state_hash = $1 AND expires_at > now() RETURNING state_hash",
               [input.arguments.state_hash]
             ) do
          {:ok, %{num_rows: 1}} -> {:ok, true}
          {:ok, %{num_rows: 0}} -> {:ok, false}
          {:error, error} -> {:error, error}
        end
      end
    end
  end

  policies do
    policy always() do
      authorize_if actor_attribute_equals(:system, true)
    end
  end
end
