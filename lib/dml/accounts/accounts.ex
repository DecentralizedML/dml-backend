defmodule Dml.Accounts do
  @behaviour Bodyguard.Policy

  import Ecto.Query, warn: false
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  alias Dml.Accounts.User
  alias Dml.Guardian
  alias Dml.Repo

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
  end

  def create_user_from_oauth(attrs \\ %{}) do
    %User{new: true}
    |> User.create_from_oauth_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  def user_from_oauth("google", %{"sub" => id, "email" => email, "given_name" => first_name, "family_name" => last_name}) do
    case Repo.get_by(User, email: email, google_uid: id) do
      nil -> create_user_from_oauth(%{email: email, google_uid: id, first_name: first_name, last_name: last_name})
      user -> {:ok, user}
    end
  end

  def user_from_oauth("facebook", %{"id" => id, "email" => email, "first_name" => first_name, "last_name" => last_name}) do
    case Repo.get_by(User, email: email, facebook_uid: id) do
      nil -> create_user_from_oauth(%{email: email, facebook_uid: id, first_name: first_name, last_name: last_name})
      user -> {:ok, user}
    end
  end

  def sign_in_user(email, password) do
    case authenticate_user(email, password) do
      {:ok, user} -> Guardian.encode_and_sign(user)
      _ -> {:error, :unauthorized}
    end
  end

  defp authenticate_user(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, user} <- get_by_email(email), do: verify_password(password, user)
  end

  defp verify_password(password, %User{} = user) when is_binary(password) do
    if checkpw(password, user.password_hash) do
      {:ok, user}
    else
      {:error, :invalid_password}
    end
  end

  defp get_by_email(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        dummy_checkpw()
        {:error, "Login error."}

      user ->
        {:ok, user}
    end
  end

  def authorize(:update_user, %User{id: id}, %User{id: id}), do: true
  def authorize(_, _, _), do: false
end
