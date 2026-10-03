defmodule ContourWeb.Auth.APIPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :contour,
    module: Contour.Auth.Guardian,
    error_handler: ContourWeb.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "api", "aud" => "contour-api"}
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
