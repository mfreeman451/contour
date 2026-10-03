defmodule Contour.Security do
  use Ash.Domain

  resources do
    resource Contour.Security.RateLimitBucket do
      define :check_quota, action: :check, args: [:key, :limit, :seconds]
    end

    resource Contour.Security.OIDCAttempt

    resource Contour.Security.Maintenance do
      define :cleanup, action: :cleanup
    end
  end
end
