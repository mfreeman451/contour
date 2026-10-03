defmodule Contour.Auth.Guardian do
  @moduledoc "Typed API JWTs with database-backed session revocation."
  use Guardian, otp_app: :contour
  alias Contour.Accounts
  alias Contour.Accounts.Scope

  @impl true
  def subject_for_token(%Scope{user: user}, _claims), do: {:ok, "user:#{user.id}"}
  def subject_for_token(_, _), do: {:error, :invalid_resource}

  @impl true
  def resource_from_claims(%{"sub" => "user:" <> id, "sid" => sid}) do
    case Accounts.scope_for_session(sid, id) do
      %Scope{} = scope -> {:ok, scope}
      nil -> {:error, :revoked_or_expired}
    end
  end

  def resource_from_claims(_), do: {:error, :invalid_claims}

  @impl true
  def verify_claims(%{"typ" => "api", "aud" => "contour-api"} = claims, _opts),
    do: {:ok, claims}

  def verify_claims(_, _), do: {:error, :invalid_token_type_or_audience}

  def issue_api_token(%Scope{session_id: sid} = scope) do
    encode_and_sign(scope, %{"sid" => sid, "aud" => "contour-api"},
      token_type: "api",
      ttl: {15, :minute}
    )
  end
end
