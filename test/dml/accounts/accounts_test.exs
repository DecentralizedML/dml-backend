defmodule Dml.AccountsTest do
  use Dml.DataCase

  alias Dml.Accounts

  describe "users" do
    alias Dml.Accounts.User

    @valid_attrs params_for(:user)
    @update_attrs params_for(:user)
    @invalid_attrs params_for(:user, email: "wrong")

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [%{user | password: nil, password_confirmation: nil}]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == %{user | password: nil, password_confirmation: nil}
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == @valid_attrs[:email]
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, changeset} = Accounts.create_user(@invalid_attrs)
      assert "has invalid format" in errors_on(changeset).email
    end

    test "create_user/1 with duplicate email returns error changeset" do
      user = user_fixture()
      params = params_for(:user, email: user.email)
      assert {:error, changeset} = Accounts.create_user(params)
      assert "has already been taken" in errors_on(changeset).email
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == @update_attrs[:email]
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert Accounts.get_user!(user.id) == %{user | password: nil, password_confirmation: nil}
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "sign_in_user/2 with valid credentials" do
      user = user_fixture()
      assert {:ok, _token, %{"sub" => id}} = Accounts.sign_in_user(user.email, user.password)
      assert id == user.id
    end

    test "sign_in_user/2 with invalid password" do
      user = user_fixture()
      assert {:error, :unauthorized} = Accounts.sign_in_user(user.email, "wrong")
    end

    test "sign_in_user/2 with invalid email" do
      assert {:error, :unauthorized} = Accounts.sign_in_user("wrong", "wrong")
    end
  end
end
