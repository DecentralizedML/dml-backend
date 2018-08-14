defmodule DmlWeb.BountyControllerTest do
  use DmlWeb.ConnCase

  alias Dml.Marketplace
  alias DmlWeb.BountyView

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    @tag :authenticated
    test "lists all bounties", %{conn: conn} do
      bounty = insert(:bounty)
      conn = get(conn, bounty_path(conn, :index))

      assert json_response(conn, 200) == render_json(BountyView, "index.json", bounties: [bounty])
    end

    test "renders errors when unauthenticated", %{conn: conn} do
      conn = get(conn, bounty_path(conn, :index))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end
  end

  describe "mine" do
    @tag :authenticated
    test "lists my bounties", %{conn: conn, user: user} do
      my_bounty = insert(:bounty, owner: user)
      _other_bounty = insert(:bounty)

      conn = get(conn, bounty_path(conn, :mine))

      assert json_response(conn, 200) == render_json(BountyView, "index.json", bounties: [%{my_bounty | owner: nil}])
    end

    test "renders errors when unauthenticated", %{conn: conn} do
      conn = get(conn, bounty_path(conn, :mine))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end
  end

  describe "create bounty" do
    @tag :authenticated
    test "renders bounty when data is valid", %{conn: conn, user: user} do
      params = params_for(:bounty)
      conn = post(conn, bounty_path(conn, :create), bounty: params)
      assert %{"id" => id} = json_response(conn, 201)

      bounty = Marketplace.get_bounty!(id)
      assert bounty.owner_id == user.id
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      params = params_for(:bounty, name: "")
      conn = post(conn, bounty_path(conn, :create), bounty: params)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when unauthenticated", %{conn: conn} do
      params = params_for(:bounty)
      conn = post(conn, bounty_path(conn, :create), bounty: params)
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end
  end

  describe "show bounty" do
    @tag :authenticated
    test "renders bounty when data is valid", %{conn: conn} do
      bounty = insert(:bounty)

      conn = get(conn, bounty_path(conn, :show, bounty.id))
      assert json_response(conn, 200) == render_json(BountyView, "show.json", bounty: bounty)
    end
  end

  describe "update bounty" do
    @tag :authenticated
    test "renders bounty when data is valid", %{conn: conn, user: user} do
      %{id: id} = bounty = insert(:bounty, owner: user)

      params = params_for(:bounty) |> Map.take([:name, :description])
      conn = put(conn, bounty_path(conn, :update, bounty), bounty: params)
      assert %{"id" => ^id} = json_response(conn, 200)

      bounty = Marketplace.get_bounty!(id)
      assert bounty.name == params[:name]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn, user: user} do
      bounty = insert(:bounty, owner: user)
      params = params_for(:bounty, %{name: ""})
      conn = put(conn, bounty_path(conn, :update, bounty), bounty: params)
      assert json_response(conn, 422)["errors"] != %{}
    end

    @tag :authenticated
    test "renders errors when trying to update someone's bounty", %{conn: conn, user: _user} do
      bounty = insert(:bounty)
      params = params_for(:bounty)
      conn = put(conn, bounty_path(conn, :update, bounty), bounty: params)
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end

    test "renders errors when unauthenticated", %{conn: conn} do
      bounty = insert(:bounty)
      params = params_for(:bounty)
      conn = put(conn, bounty_path(conn, :update, bounty), bounty: params)
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end
  end

  describe "open bounty" do
    @tag :authenticated
    test "renders bounty when transition is valid", %{conn: conn, user: user} do
      %{id: id} = bounty = insert(:bounty, owner: user)

      conn = put(conn, bounty_bounty_path(conn, :open, bounty))
      assert %{"id" => ^id} = json_response(conn, 200)

      bounty = Marketplace.get_bounty!(id)
      assert bounty.state == "open"
    end

    @tag :authenticated
    test "renders errors when transition is invalid", %{conn: conn, user: user} do
      bounty = insert(:bounty, owner: user, state: "finished")
      conn = put(conn, bounty_bounty_path(conn, :open, bounty))
      assert json_response(conn, 422)["errors"] != %{}
    end

    @tag :authenticated
    test "renders errors when trying to update someone's bounty", %{conn: conn, user: _user} do
      bounty = insert(:bounty)
      conn = put(conn, bounty_bounty_path(conn, :open, bounty))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end

    test "renders errors when unauthenticated", %{conn: conn} do
      bounty = insert(:bounty)
      conn = put(conn, bounty_bounty_path(conn, :open, bounty))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end
  end

  describe "close bounty" do
    @tag :authenticated
    test "renders bounty when transition is valid", %{conn: conn, user: user} do
      %{id: id} = bounty = insert(:bounty, owner: user, state: "open")

      conn = put(conn, bounty_bounty_path(conn, :close, bounty))
      assert %{"id" => ^id} = json_response(conn, 200)

      bounty = Marketplace.get_bounty!(id)
      assert bounty.state == "closed"
    end

    @tag :authenticated
    test "renders errors when transition is invalid", %{conn: conn, user: user} do
      bounty = insert(:bounty, owner: user, state: "finished")
      conn = put(conn, bounty_bounty_path(conn, :close, bounty))
      assert json_response(conn, 422)["errors"] != %{}
    end

    @tag :authenticated
    test "renders errors when trying to update someone's bounty", %{conn: conn, user: _user} do
      bounty = insert(:bounty)
      conn = put(conn, bounty_bounty_path(conn, :close, bounty))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end

    test "renders errors when unauthenticated", %{conn: conn} do
      bounty = insert(:bounty)
      conn = put(conn, bounty_bounty_path(conn, :close, bounty))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end
  end

  describe "finish bounty" do
    @tag :authenticated
    test "renders bounty when transition is valid", %{conn: conn, user: user} do
      %{id: id} = bounty = insert(:bounty, owner: user, state: "closed")

      conn = put(conn, bounty_bounty_path(conn, :finish, bounty))
      assert %{"id" => ^id} = json_response(conn, 200)

      bounty = Marketplace.get_bounty!(id)
      assert bounty.state == "finished"
    end

    @tag :authenticated
    test "renders errors when trying to update someone's bounty", %{conn: conn, user: _user} do
      bounty = insert(:bounty)
      conn = put(conn, bounty_bounty_path(conn, :finish, bounty))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end

    test "renders errors when unauthenticated", %{conn: conn} do
      bounty = insert(:bounty)
      conn = put(conn, bounty_bounty_path(conn, :finish, bounty))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end
  end
end
