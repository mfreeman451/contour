defmodule ContourWeb.UserSocket do
  use Phoenix.Socket
  alias Contour.Auth.Guardian

  @impl true
  def connect(%{"token" => token}, socket, _connect_info)
      when is_binary(token) and byte_size(token) <= 4096 do
    with {:ok, claims} <- Guardian.decode_and_verify(token),
         {:ok, scope} <- Guardian.resource_from_claims(claims) do
      {:ok, assign(socket, :current_scope, scope)}
    else
      _ -> :error
    end
  end

  def connect(_, _, _), do: :error

  @impl true
  def id(socket), do: "sessions:#{socket.assigns.current_scope.session_id}"
end
