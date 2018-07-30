defmodule DmlWeb.UserController do
  use DmlWeb, :controller

  alias Dml.Accounts
  alias Dml.Accounts.User
  alias Dml.Guardian
  alias Dml.Guardian.Plug

  action_fallback DmlWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("jwt.json", user: user, jwt: token)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def authenticate(conn, %{"email" => email, "password" => password}) do
    case Accounts.sign_in_user(email, password) do
      {:ok, token, claims} ->
        {:ok, user} = Guardian.resource_from_claims(claims)
        conn |> render("jwt.json", user: user, jwt: token)
      _ -> {:error, :unauthorized}
    end
  end

  def update(conn, %{"user" => user_params}) do
    user = Plug.current_resource(conn)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  # def delete(conn, %{"id" => id}) do
  #   user = Accounts.get_user!(id)
  #   with {:ok, %User{}} <- Accounts.delete_user(user) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
