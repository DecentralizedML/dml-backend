defmodule DmlWeb.UserControllerTest do
  use DmlWeb.ConnCase

  alias Dml.Accounts
  alias Dml.Accounts.User
  alias Dml.Guardian
  alias DmlWeb.UserView

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

  describe "update user" do
    @tag :authenticated
    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = _user} do
      params = params_for(:user) |> Map.take([:email, :first_name, :last_name])
      conn = put(conn, user_path(conn, :update), user: params)
      assert %{"id" => ^id} = json_response(conn, 200)

      user = Accounts.get_user!(id)
      conn = get(conn, user_path(conn, :show, id))
      assert json_response(conn, 200) == render_json(UserView, "show.json", user: user)
      assert json_response(conn, 200)["email"] == params[:email]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      params = params_for(:user, %{email: "wrong"})
      conn = put(conn, user_path(conn, :update), user: params)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when data is valid & user is not authenticated", %{conn: conn} do
      params = params_for(:user)
      conn = put(conn, user_path(conn, :update), user: params)
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end
  end
end
