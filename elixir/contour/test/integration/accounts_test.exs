defmodule Contour.AccountsTest do
  use Contour.DataCase, async: true
  import Contour.IdentityFixtures
  alias Contour.Accounts
  alias Contour.Accounts.{SystemActor, User}

  test "Google identity is keyed by issuer and subject; email does not link accounts" do
    claims = claims()
    {:ok, first} = Accounts.from_google_claims(claims)
    {:ok, updated} = Accounts.from_google_claims(%{claims | "name" => "Renamed"})
    {:ok, other} = Accounts.from_google_claims(%{claims | "sub" => "a-different-subject"})
    assert updated.id == first.id
    assert updated.display_name == "Renamed"
    assert other.id != first.id
    assert other.email == first.email
  end

  test "unverified email and foreign issuers cannot provision identities" do
    for overrides <- [%{"email_verified" => false}, %{"iss" => "https://untrusted.test"}] do
      assert {:error, :invalid_identity} = Accounts.from_google_claims(claims(overrides))
    end

    assert Ash.read!(User, actor: %SystemActor{}) == []
  end

  test "ordinary actors cannot provision users or inspect other users" do
    %{user: user} = identity()

    assert {:error, %Ash.Error.Forbidden{}} =
             Ash.create(
               User,
               %{
                 oidc_issuer: "https://accounts.google.com",
                 oidc_subject: "forged",
                 email: "forged@example.test",
                 display_name: "Forged"
               },
               action: :from_google,
               actor: user
             )

    {:ok, other} = Accounts.from_google_claims(claims())
    assert Ash.read!(User, actor: user) |> Enum.map(& &1.id) == [user.id]
    refute other.id == user.id
  end

  test "only hashed opaque session credentials persist, and disabling a user invalidates them" do
    %{user: user, token: token, session: session} = identity()
    assert session.token_hash != token
    assert Accounts.scope_for_token(token).user.id == user.id
    assert Accounts.scope_for_token("forged") == nil
    Ash.update!(user, %{}, action: :disable, actor: %SystemActor{})
    assert Accounts.scope_for_token(token) == nil

    assert {:error, :disabled} =
             Accounts.from_google_claims(claims(%{"sub" => user.oidc_subject}))
  end
end
