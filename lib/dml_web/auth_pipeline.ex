defmodule Dml.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :dml,
    module: Dml.Guardian,
    error_handler: DmlWeb.FallbackController

  plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
end
