defmodule Contour.SecurityTest do
  use Contour.DataCase, async: true
  alias Contour.Security.{OIDCAttempt, RateLimiter}
  alias Contour.Accounts.SystemActor
  import Contour.IdentityFixtures

  test "concurrent callers share one bounded quota" do
    parent = self()

    results =
      1..24
      |> Task.async_stream(
        fn _ ->
          Ecto.Adapters.SQL.Sandbox.allow(Contour.Repo, parent, self())
          RateLimiter.check("shared-test-quota", 5, 3600)
        end,
        max_concurrency: 12
      )
      |> Enum.map(fn {:ok, result} -> result end)

    assert Enum.count(results, &(&1 == :ok)) == 5
    assert Enum.count(results, &match?({:error, {:limited, 3600}}, &1)) == 19
  end

  test "OIDC state admission is single-use and rejects expired attempts" do
    state = :crypto.strong_rand_bytes(32)
    digest = Contour.Accounts.digest(state)

    Ash.create!(
      OIDCAttempt,
      %{state_hash: digest, expires_at: DateTime.add(DateTime.utc_now(), 300)},
      actor: %SystemActor{}
    )

    consume = fn ->
      OIDCAttempt
      |> Ash.ActionInput.for_action(:consume, %{state_hash: digest}, actor: %SystemActor{})
      |> Ash.run_action()
    end

    assert consume.() == {:ok, true}
    assert consume.() == {:ok, false}

    Ash.create!(
      OIDCAttempt,
      %{state_hash: digest, expires_at: DateTime.add(DateTime.utc_now(), -1)},
      actor: %SystemActor{}
    )

    assert consume.() == {:ok, false}
  end

  test "OIDC callback without a matching browser challenge fails before exchanging credentials" do
    assert {:error, :authentication_failed} = Contour.Auth.OIDC.exchange(nil, "state", "code")
  end

  test "AshOban cleanup expires stale credentials and preserves active sessions" do
    active = identity()
    stale = identity()

    Contour.Repo.query!(
      "UPDATE sessions SET expires_at = now() - interval '1 second' WHERE id = $1",
      [Ecto.UUID.dump!(stale.session.id)]
    )

    assert :ok = Contour.Security.cleanup(actor: %SystemActor{})
    assert Contour.Accounts.scope_for_token(stale.token) == nil
    assert Contour.Accounts.scope_for_token(active.token).session_id == active.session.id
  end
end
