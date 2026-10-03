defmodule Contour.Security.RateLimitBucket do
  use Ash.Resource,
    domain: Contour.Security,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "rate_limit_buckets"
    repo Contour.Repo
  end

  attributes do
    attribute :key, :binary, primary_key?: true, allow_nil?: false, sensitive?: true
    attribute :window, :integer, primary_key?: true, allow_nil?: false
    attribute :count, :integer, allow_nil?: false
    attribute :expires_at, :integer, allow_nil?: false
  end

  actions do
    defaults [:read]

    action :check, :map do
      argument :key, :string, allow_nil?: false
      argument :limit, :integer, allow_nil?: false, constraints: [min: 1, max: 100_000]
      argument :seconds, :integer, allow_nil?: false, constraints: [min: 1, max: 3600]
      run Contour.Security.RateLimiter
    end
  end

  policies do
    policy always() do
      authorize_if actor_attribute_equals(:system, true)
    end
  end
end
