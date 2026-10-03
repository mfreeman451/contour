defmodule Contour.Accounts.SystemActor do
  @moduledoc "Internal identity operations only. Never constructed from request parameters."
  defstruct system: true
end
