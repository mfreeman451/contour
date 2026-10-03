defmodule Contour.IdentityFixtures do
  def claims(overrides \\ %{}) do
    Map.merge(
      %{
        "iss" => "https://accounts.google.com",
        "sub" => Ecto.UUID.generate(),
        "email" => "commander@example.test",
        "email_verified" => true,
        "name" => "Test commander"
      },
      overrides
    )
  end

  def identity do
    {:ok, user} = Contour.Accounts.from_google_claims(claims())
    {:ok, token, session} = Contour.Accounts.create_session(user)
    scope = %Contour.Accounts.Scope{user: user, session_id: session.id}
    {:ok, jwt, _claims} = Contour.Auth.Guardian.issue_api_token(scope)
    %{user: user, token: token, session: session, scope: scope, jwt: jwt}
  end
end
