defmodule Contour.Accounts.Session do
  use Ash.Resource,
    domain: Contour.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "sessions"
    repo Contour.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:user_id, :token_hash, :expires_at]
    end

    read :valid do
      filter expr(expires_at > now() and is_nil(user.disabled_at))
    end
  end

  policies do
    policy always() do
      authorize_if actor_attribute_equals(:system, true)
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :token_hash, :binary, allow_nil?: false, sensitive?: true
    attribute :expires_at, :utc_datetime_usec, allow_nil?: false
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :user, Contour.Accounts.User, allow_nil?: false, attribute_type: :uuid
  end

  identities do
    identity :token, [:token_hash]
  end
end
