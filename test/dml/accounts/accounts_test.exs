defmodule Dml.AccountsTest do
  use Dml.DataCase

  alias Dml.Accounts

  describe "users" do
    alias Dml.Accounts.User

    @valid_attrs params_for(:user)
    @update_attrs params_for(:user) |> Map.drop([:email, :password, :password_confirmation])
    @invalid_attrs params_for(:user, email: "wrong")

    test "list_users/0 returns all users" do
      user = insert(:user)
      users = Accounts.list_users()

      assert Enum.count(users) == 1
      assert has_element_by_id(users, %{id: user.id})
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert Accounts.get_user!(user.id).id == user.id
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == @valid_attrs[:email]
      assert Regex.match?(~r/\$2b\$04\$.*/, user.password_hash)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, changeset} = Accounts.create_user(@invalid_attrs)
      assert "has invalid format" in errors_on(changeset).email
    end

    test "create_user/1 with duplicate email returns error changeset" do
      user = insert(:user)
      params = params_for(:user, email: user.email)
      assert {:error, changeset} = Accounts.create_user(params)
      assert "has already been taken" in errors_on(changeset).email
    end

    test "update_user/2 with valid data (only name) updates the user" do
      user = insert(:user)
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.first_name == @update_attrs[:first_name]
      assert user.last_name == @update_attrs[:last_name]
      assert Regex.match?(~r/\$2b\$04\$.*/, user.security_answer1)
      assert user.country
    end

    test "update_user/2 with valid data (ETH address) updates the user" do
      user = insert(:user)
      assert {:ok, user} = Accounts.update_user(user, %{wallet_address: "0x32be343b94f860124dc4fee278fdcbd38c102d88"})
      assert %User{} = user
      assert user.wallet_address == "0x32be343b94f860124dc4fee278fdcbd38c102d88"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, %{first_name: ""})
    end

    test "update_user/2 with invalid ETH address returns error changeset" do
      user = insert(:user)
      assert {:error, changeset} = Accounts.update_user(user, %{wallet_address: "ha"})
      assert "has invalid format" in errors_on(changeset).wallet_address
    end

    test "update_user/2 with invalid country code returns error changeset" do
      user = insert(:user)
      assert {:error, changeset} = Accounts.update_user(user, %{country: "Brasil"})
      assert "is invalid" in errors_on(changeset).country
      assert {:error, changeset} = Accounts.update_user(user, %{country: "br"})
      assert "is invalid" in errors_on(changeset).country
    end

    test "sign_in_user/2 with valid credentials" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      assert {:ok, _token, %{"sub" => id}} = Accounts.sign_in_user(user.email, user.password)
      assert id == user.id
    end

    test "sign_in_user/2 with invalid password" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      assert {:error, :unauthorized} = Accounts.sign_in_user(user.email, "wrong")
    end

    test "sign_in_user/2 with invalid email" do
      assert {:error, :unauthorized} = Accounts.sign_in_user("wrong", "wrong")
    end
  end
end
