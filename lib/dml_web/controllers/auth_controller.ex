defmodule DmlWeb.AuthController do
  use DmlWeb, :controller

  alias Dml.Accounts
  alias Dml.Accounts.{FacebookClient, GoogleClient, User}
  alias Dml.Guardian
  alias DmlWeb.UserView

  action_fallback(DmlWeb.FallbackController)

  def index(conn, %{"provider" => provider}) do
    conn |> redirect(external: authorize_url(provider))
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    with token <- get_token(code, provider),
         {:ok, data} <- get_user(token, provider),
         {:ok, %User{} = user} <- Accounts.user_from_oauth(provider, data),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> set_response_status(user)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render(UserView, "jwt.json", user: user, jwt: token)
    end
  end

  defp authorize_url("google"), do: GoogleClient.authorize_url!()
  defp authorize_url("facebook"), do: FacebookClient.authorize_url!()
  defp authorize_url(_), do: raise("No matching provider available")

  defp get_token(code, "google"), do: GoogleClient.get_token!(code: code)
  defp get_token(code, "facebook"), do: FacebookClient.get_token!(code: code)
  defp get_token(_, _), do: raise("No matching provider available")

  defp get_user(token, "google"), do: GoogleClient.get_user(token)
  defp get_user(token, "facebook"), do: FacebookClient.get_user(token)
  defp get_user(_, _), do: raise("No matching provider available")

  defp set_response_status(conn, %User{new: true}), do: conn |> put_status(:created)
  defp set_response_status(conn, %User{new: _}), do: conn |> put_status(:ok)
end
