defmodule Contour.Auth.OIDC do
  @moduledoc "Google code flow: full state comparison, nonce, S256 PKCE and single-use attempts."
  alias Contour.Accounts
  alias Contour.Security.OIDCAttempt
  alias Contour.Accounts.SystemActor

  def authorize do
    state = random()
    challenge = %{state: state, nonce: random(), verifier: random()}
    cfg = Application.fetch_env!(:contour, :oidc)

    with {:ok, url} <-
           Oidcc.create_redirect_url(
             Contour.OIDCProvider,
             cfg[:client_id],
             cfg[:client_secret],
             %{
               redirect_uri: cfg[:redirect_uri],
               scope: ["openid", "email", "profile"],
               state: state,
               nonce: challenge.nonce,
               pkce_verifier: challenge.verifier,
               require_pkce: true,
               request_opts: request_opts()
             }
           ),
         {:ok, _} <-
           Ash.create(
             OIDCAttempt,
             %{
               state_hash: Accounts.digest(state),
               expires_at: DateTime.add(DateTime.utc_now(), 5, :minute)
             },
             actor: %SystemActor{}
           ) do
      {:ok, IO.iodata_to_binary(url), challenge}
    end
  end

  def exchange(%{state: expected, nonce: nonce, verifier: verifier}, state, code)
      when is_binary(state) and is_binary(code) and byte_size(code) <= 4096 do
    cfg = Application.fetch_env!(:contour, :oidc)

    with true <- Plug.Crypto.secure_compare(state, expected),
         {:ok, true} <-
           OIDCAttempt
           |> Ash.ActionInput.for_action(:consume, %{state_hash: Accounts.digest(state)},
             actor: %SystemActor{}
           )
           |> Ash.run_action(),
         {:ok, %Oidcc.Token{id: %Oidcc.Token.Id{claims: claims}}} <-
           Oidcc.retrieve_token(
             code,
             Contour.OIDCProvider,
             cfg[:client_id],
             cfg[:client_secret],
             %{
               redirect_uri: cfg[:redirect_uri],
               nonce: nonce,
               pkce_verifier: verifier,
               require_pkce: true,
               scope: ["openid", "email", "profile"],
               request_opts: request_opts()
             }
           ) do
      Accounts.from_google_claims(claims)
    else
      _ -> {:error, :authentication_failed}
    end
  end

  def exchange(_, _, _), do: {:error, :authentication_failed}

  def request_opts,
    do: %{
      timeout: 10_000,
      ssl: [
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        customize_hostname_check: [match_fun: :public_key.pkix_verify_hostname_match_fun(:https)]
      ]
    }

  defp random, do: :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
end
