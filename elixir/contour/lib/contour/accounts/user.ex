defmodule Contour.Accounts.User do
  use Ash.Resource,
    domain: Contour.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "users"
    repo Contour.Repo
  end

  actions do
    defaults [:read]

    create :from_google do
      accept [:oidc_issuer, :oidc_subject, :email, :display_name]
      upsert? true
      upsert_identity :oidc_identity
      upsert_fields [:email, :display_name]
    end

    update :disable do
      accept []
      change set_attribute(:disabled_at, &DateTime.utc_now/0)
    end
  end

  policies do
    bypass actor_attribute_equals(:system, true) do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if expr(id == ^actor(:id) and is_nil(disabled_at))
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :oidc_issuer, :string, allow_nil?: false, sensitive?: true

    attribute :oidc_subject, :string,
      allow_nil?: false,
      sensitive?: true,
      constraints: [max_length: 255]

    attribute :email, :string,
      allow_nil?: false,
      public?: true,
      sensitive?: true,
      constraints: [max_length: 254]

    attribute :display_name, :string,
      allow_nil?: false,
      public?: true,
      constraints: [min_length: 1, max_length: 80]

    attribute :disabled_at, :utc_datetime_usec
    timestamps()
  end

  identities do
    identity :oidc_identity, [:oidc_issuer, :oidc_subject]
  end
end
