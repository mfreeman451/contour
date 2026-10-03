defmodule ContourWeb.AuthenticationTest do
  use ContourWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Contour.IdentityFixtures
  alias Contour.Accounts
  alias Contour.Auth.Guardian

  setup do: {:ok, identity()}

  test "API accepts a valid bearer credential and returns only public identity fields", %{
    conn: conn,
    jwt: jwt,
    user: user
  } do
    conn = conn |> put_req_header("authorization", "Bearer " <> jwt) |> get(~p"/api/v1/me")

    assert json_response(conn, 200) == %{
             "data" => %{
               "id" => user.id,
               "display_name" => user.display_name,
               "email" => user.email
             }
           }

    assert get_resp_header(conn, "cache-control") == ["no-store"]
  end

  test "API rejects browser-only credentials and malformed or differently typed JWTs", %{
    token: token,
    scope: scope,
    jwt: valid
  } do
    {:ok, access, _} =
      Guardian.encode_and_sign(scope, %{"sid" => scope.session_id, "aud" => "contour-api"},
        token_type: "access"
      )

    {:ok, wrong_audience, _} =
      Guardian.encode_and_sign(scope, %{"sid" => scope.session_id, "aud" => "other"},
        token_type: "api"
      )

    {:ok, expired, _} =
      Guardian.encode_and_sign(
        scope,
        %{
          "sid" => scope.session_id,
          "aud" => "contour-api",
          "exp" => System.os_time(:second) - 120
        },
        token_type: "api"
      )

    {:ok, valid_claims} = Guardian.decode_and_verify(valid)

    {_, wrong_issuer} =
      JOSE.JWK.from_oct(Guardian.config(:secret_key))
      |> JOSE.JWT.sign(%{"alg" => "HS256"}, Map.put(valid_claims, "iss", "untrusted"))
      |> JOSE.JWS.compact()

    [header, payload, _] = String.split(valid, ".")

    tampered =
      Enum.join(
        [header, payload, Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)],
        "."
      )

    for jwt <- [nil, "not-a-jwt", access, wrong_audience, expired, wrong_issuer, tampered] do
      conn = build_conn() |> init_test_session(session_token: token)
      conn = if jwt, do: put_req_header(conn, "authorization", "Bearer " <> jwt), else: conn
      assert conn |> get(~p"/api/v1/me") |> json_response(401) == %{"error" => "unauthorized"}
    end
  end

  test "revocation denies subsequent API and socket admission", %{jwt: jwt, scope: scope} do
    assert {:ok, socket} =
             ContourWeb.UserSocket.connect(%{"token" => jwt}, %Phoenix.Socket{}, %{})

    assert ContourWeb.UserSocket.id(socket) == "sessions:" <> scope.session_id

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer " <> jwt)
      |> delete(~p"/api/v1/session")

    assert response(conn, 204) == ""

    assert build_conn()
           |> put_req_header("authorization", "Bearer " <> jwt)
           |> get(~p"/api/v1/me")
           |> json_response(401) == %{"error" => "unauthorized"}

    assert ContourWeb.UserSocket.connect(%{"token" => jwt}, %Phoenix.Socket{}, %{}) == :error
  end

  test "the LiveView shell requires a live session and disconnects when revoked", %{
    conn: conn,
    token: token,
    scope: scope
  } do
    assert {:error, {:redirect, %{to: "/login"}}} = live(conn, ~p"/lobby")
    {:ok, view, html} = conn |> init_test_session(session_token: token) |> live(~p"/lobby")
    assert html =~ "Welcome, Test commander."
    Accounts.revoke_session(scope)
    assert_redirect(view, "/login")
  end

  test "browser mutations require CSRF protection", %{conn: conn, token: token} do
    conn =
      conn
      |> init_test_session(session_token: token)
      |> put_private(:plug_skip_csrf_protection, false)

    assert_raise Plug.CSRFProtection.InvalidCSRFTokenError, fn ->
      post(conn, ~p"/auth/api-token")
    end
  end

  test "untrusted forwarding headers cannot reset the API IP quota", %{jwt: jwt} do
    for _ <- 1..300, do: :ok = Contour.Security.RateLimiter.check("api:ip:127.0.0.1", 300)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer " <> jwt)
      |> put_req_header("x-forwarded-for", "203.0.113.15")
      |> get(~p"/api/v1/me")

    assert json_response(conn, 429) == %{"error" => "rate_limited"}
    assert [retry] = get_resp_header(conn, "retry-after")
    assert String.to_integer(retry) > 0
  end
end
