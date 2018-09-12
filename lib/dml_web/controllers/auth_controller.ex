defmodule DmlWeb.AuthController do
  use DmlWeb, :controller

  alias Dml.Accounts
  alias Dml.Accounts.{GoogleClient, User}
  alias Dml.Guardian
  alias DmlWeb.UserView

  action_fallback(DmlWeb.FallbackController)

  # TODO: Do not merge this! Remove this endpoint when we're ready with the OAuth changes
  def index(conn, %{"provider" => provider}) do
    conn |> redirect(external: authorize_url(provider))
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    with token <- get_token(code, provider),
         {:ok, data} <- get_user(token, provider),
         {:ok, %User{} = user} <- Accounts.user_from_oauth(provider, data),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render(UserView, "jwt.json", user: user, jwt: token)
    end
  end

  defp authorize_url("google"), do: GoogleClient.authorization_url()
  defp authorize_url(_), do: raise("No matching provider available")

  defp get_token(code, "google"), do: GoogleClient.get_token(code: code)
  defp get_token(_, _), do: raise("No matching provider available")

  defp get_user(token, "google"), do: GoogleClient.get_user(token)
  defp get_user(_, _), do: raise("No matching provider available")
end
