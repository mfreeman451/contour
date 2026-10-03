defmodule Contour.Accounts.Scope do
  @moduledoc "Authorization context carried by browser, LiveView and API boundaries."
  defstruct [:user, :session_id]
end
