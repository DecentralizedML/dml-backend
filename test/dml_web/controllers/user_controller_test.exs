defmodule DmlWeb.UserControllerTest do
  use DmlWeb.ConnCase

  alias Dml.Accounts
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
    test "renders user when data is valid", %{conn: conn} do
      params = params_for(:user)
      conn = post(conn, user_path(conn, :create), user: params)
      assert %{"id" => id} = json_response(conn, 201)

      user = Accounts.get_user!(id)
      conn = get(conn, user_path(conn, :show, id))
      assert json_response(conn, 200) == render_json(UserView, "show.json", user: user)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      params = params_for(:user, email: "wrong")
      conn = post(conn, user_path(conn, :create), user: params)
      assert json_response(conn, 422)["errors"] != %{}
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
