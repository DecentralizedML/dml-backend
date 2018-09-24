defmodule DmlWeb.AlgorithmControllerTest do
  use DmlWeb.ConnCase

  alias Dml.Marketplace
  alias DmlWeb.AlgorithmView

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    @tag :authenticated
    test "lists all published algorithms", %{conn: conn} do
      algorithm = insert(:algorithm)
      conn = get(conn, algorithm_path(conn, :index))

      assert json_response(conn, 200) == render_json(AlgorithmView, "index.json", algorithms: [algorithm])
    end

    test "renders errors when unauthenticated", %{conn: conn} do
      conn = get(conn, algorithm_path(conn, :index))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end
  end

  describe "mine" do
    @tag :authenticated
    test "lists all my algorithms", %{conn: conn, user: user} do
      my_algorithm = insert(:algorithm, user: user)
      _other_algorithm = insert(:algorithm)

      conn = get(conn, algorithm_path(conn, :mine))
      rendered = render_json(AlgorithmView, "index.json", algorithms: [%{my_algorithm | user: nil}])

      assert json_response(conn, 200) == rendered
    end

    test "renders errors when unauthenticated", %{conn: conn} do
      conn = get(conn, algorithm_path(conn, :mine))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end
  end

  describe "create algorithm" do
    @tag :authenticated
    test "renders algorithm when data is valid", %{conn: conn, user: user} do
      params = params_for(:algorithm)
      conn = post(conn, algorithm_path(conn, :create), algorithm: params)
      assert %{"id" => id} = json_response(conn, 201)

      algorithm = Marketplace.get_algorithm!(id)
      assert algorithm.user_id == user.id
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      params = params_for(:algorithm, title: "")
      conn = post(conn, algorithm_path(conn, :create), algorithm: params)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when unauthenticated", %{conn: conn} do
      params = params_for(:algorithm)
      conn = post(conn, algorithm_path(conn, :create), algorithm: params)
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end
  end

  describe "show algorithm" do
    @tag :authenticated
    test "renders algorithm when data is valid", %{conn: conn} do
      algorithm = insert(:algorithm)

      conn = get(conn, algorithm_path(conn, :show, algorithm.id))
      assert json_response(conn, 200) == render_json(AlgorithmView, "show.json", algorithm: algorithm)
    end
  end

  describe "update algorithm" do
    @tag :authenticated
    test "renders algorithm when data is valid", %{conn: conn, user: user} do
      %{id: id} = algorithm = insert(:algorithm, user: user)

      params = params_for(:algorithm) |> Map.take([:title, :description])
      conn = put(conn, algorithm_path(conn, :update, algorithm), algorithm: params)
      assert %{"id" => ^id} = json_response(conn, 200)

      algorithm = Marketplace.get_algorithm!(id)
      assert algorithm.title == params[:title]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn, user: user} do
      algorithm = insert(:algorithm, user: user)
      params = params_for(:algorithm, %{title: ""})
      conn = put(conn, algorithm_path(conn, :update, algorithm), algorithm: params)
      assert json_response(conn, 422)["errors"] != %{}
    end

    @tag :authenticated
    test "renders errors when trying to update someone's algorithm", %{conn: conn, user: _user} do
      algorithm = insert(:algorithm)
      params = params_for(:algorithm)
      conn = put(conn, algorithm_path(conn, :update, algorithm), algorithm: params)
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end

    test "renders errors when unauthenticated", %{conn: conn} do
      algorithm = insert(:algorithm)
      params = params_for(:algorithm)
      conn = put(conn, algorithm_path(conn, :update, algorithm), algorithm: params)
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end
  end
end
