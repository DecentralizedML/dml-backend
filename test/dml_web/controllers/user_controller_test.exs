defmodule DmlWeb.UserControllerTest do
  use DmlWeb.ConnCase

  alias Dml.Accounts
  alias Dml.Guardian
  alias DmlWeb.UserView
  # alias Dml.Accounts.User

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      user = insert(:user)
      conn = get(conn, user_path(conn, :index))

      assert json_response(conn, 200) == render_json(UserView, "index.json", users: [user])
    end
  end

  describe "create user" do
    test "renders JWT when data is valid", %{conn: conn} do
      params = params_for(:user)
      conn = post(conn, user_path(conn, :create), user: params)
      assert %{"jwt" => token} = json_response(conn, 201)

      {:ok, claims} = Guardian.decode_and_verify(token)
      {:ok, user} = Guardian.resource_from_claims(claims)

      conn = get(conn, user_path(conn, :show, user.id))
      assert json_response(conn, 200) == render_json(UserView, "show.json", user: user)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      params = params_for(:user, email: "wrong")
      conn = post(conn, user_path(conn, :create), user: params)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "authenticate user" do
    test "renders JWT when data is valid", %{conn: conn} do
      params = params_for(:user)
      {:ok, user} = Accounts.create_user(params)

      conn = post(conn, user_path(conn, :authenticate), email: user.email, password: user.password)
      assert %{"jwt" => token} = json_response(conn, 200)

      {:ok, claims} = Guardian.decode_and_verify(token)
      {:ok, token_user} = Guardian.resource_from_claims(claims)

      assert token_user == %{user | password: nil, password_confirmation: nil}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      params = params_for(:user)
      {:ok, user} = Accounts.create_user(params)

      conn = post(conn, user_path(conn, :authenticate), email: user.email, password: "invalid")
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end
  end

  # describe "update user" do
  #   setup [:create_user]

  #   test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
  #     conn = put conn, user_path(conn, :update, user), user: @update_attrs
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get conn, user_path(conn, :show, id)
  #     assert json_response(conn, 200)["data"] == %{
  #       "id" => id,
  #       "email" => "some updated email",
  #       "password_hash" => "some updated password_hash",
  #       "wallet_address" => "some updated wallet_address"}
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, user: user} do
  #     conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete user" do
  #   setup [:create_user]

  #   test "deletes chosen user", %{conn: conn, user: user} do
  #     conn = delete conn, user_path(conn, :delete, user)
  #     assert response(conn, 204)
  #     assert_error_sent 404, fn ->
  #       get conn, user_path(conn, :show, user)
  #     end
  #   end
  # end
end
