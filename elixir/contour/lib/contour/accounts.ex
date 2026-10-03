defmodule Contour.Accounts do
  use Ash.Domain
  require Ash.Query
  alias Contour.Accounts.{Scope, Session, SystemActor, User}

  resources do
    resource User
    resource Session
  end

  def from_google_claims(
        %{
          "iss" => "https://accounts.google.com" = issuer,
          "sub" => subject,
          "email" => email,
          "email_verified" => true
        } = claims
      )
      when is_binary(subject) and is_binary(email) do
    name =
      case Map.get(claims, "name") do
        value when is_binary(value) and value != "" -> value
        _ -> email
      end

    attrs = %{
      oidc_issuer: issuer,
      oidc_subject: subject,
      email: email,
      display_name: String.slice(name, 0, 80)
    }

    User
    |> Ash.Changeset.for_create(:from_google, attrs, actor: %SystemActor{})
    |> Ash.create()
    |> enabled_user()
  end

  def from_google_claims(_), do: {:error, :invalid_identity}
  defp enabled_user({:ok, %User{disabled_at: nil}} = result), do: result
  defp enabled_user({:ok, %User{}}), do: {:error, :disabled}
  defp enabled_user({:error, _} = result), do: result

  def create_session(%User{disabled_at: nil} = user) do
    token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)

    attrs = %{
      user_id: user.id,
      token_hash: digest(token),
      expires_at: DateTime.add(DateTime.utc_now(), 12, :hour)
    }

    with {:ok, session} <-
           Session
           |> Ash.Changeset.for_create(:create, attrs, actor: %SystemActor{})
           |> Ash.create(),
         do: {:ok, token, session}
  end

  def scope_for_token(token) when is_binary(token) and byte_size(token) <= 128 do
    Session |> Ash.Query.filter(token_hash == ^digest(token)) |> load_scope()
  end

  def scope_for_token(_), do: nil

  def scope_for_session(id, user_id) do
    with {:ok, id} <- Ecto.UUID.cast(id), {:ok, user_id} <- Ecto.UUID.cast(user_id) do
      Session |> Ash.Query.filter(id == ^id and user_id == ^user_id) |> load_scope()
    else
      :error -> nil
    end
  end

  def revoke_session(%Scope{session_id: id}) do
    case Session |> Ash.Query.filter(id == ^id) |> Ash.read_one!(actor: %SystemActor{}) do
      nil -> :ok
      session -> Ash.destroy!(session, actor: %SystemActor{})
    end

    Phoenix.PubSub.broadcast(Contour.PubSub, "sessions:#{id}", :revoked)
    ContourWeb.Endpoint.broadcast("sessions:#{id}", "disconnect", %{})
    :ok
  end

  defp load_scope(query) do
    query =
      query |> Ash.Query.for_read(:valid, %{}, actor: %SystemActor{}) |> Ash.Query.load(:user)

    case Ash.read_one!(query) do
      %Session{user: user} = session -> %Scope{user: user, session_id: session.id}
      nil -> nil
    end
  end

  def digest(value), do: :crypto.hash(:sha256, value)
end
