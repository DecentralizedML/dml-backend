defmodule DmlWeb.EnrollmentControllerTest do
  use DmlWeb.ConnCase

  alias Dml.Marketplace
  alias DmlWeb.EnrollmentView

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    @tag :authenticated
    test "lists all enrollments of a bounty created by the user", %{conn: conn, user: user} do
      bounty = insert(:bounty, owner: user)
      enrollment = insert(:enrollment, bounty: bounty)
      _other_enrollment = insert(:enrollment)
      conn = get(conn, bounty_enrollment_path(conn, :index, bounty))

      assert json_response(conn, 200) == render_json(EnrollmentView, "index.json", enrollments: [enrollment])
    end

    @tag :authenticated
    test "lists all enrollments of a bounty created by someone else", %{conn: conn} do
      bounty = insert(:bounty)
      conn = get(conn, bounty_enrollment_path(conn, :index, bounty))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end

    test "renders errors when unauthenticated", %{conn: conn} do
      bounty = insert(:bounty)
      conn = get(conn, bounty_enrollment_path(conn, :index, bounty))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end
  end

  describe "enroll in bounty" do
    @tag :authenticated
    test "renders enrollment bounty is open", %{conn: conn, user: user} do
      bounty = insert(:bounty, state: "open")

      conn = post(conn, bounty_enrollment_path(conn, :create, bounty))
      assert %{"id" => id} = json_response(conn, 200)

      enrollment = Marketplace.get_enrollment!(id)
      assert enrollment.user_id == user.id
      assert enrollment.bounty_id == bounty.id
      assert enrollment.state == "pending"
    end

    @tag :authenticated
    test "renders errors when trying to enroll in pending bounty", %{conn: conn, user: _user} do
      bounty = insert(:bounty, state: "pending")

      conn = post(conn, bounty_enrollment_path(conn, :create, bounty))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end

    @tag :authenticated
    test "renders errors when trying to enroll in closed bounty", %{conn: conn, user: _user} do
      bounty = insert(:bounty, state: "closed")

      conn = post(conn, bounty_enrollment_path(conn, :create, bounty))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end

    @tag :authenticated
    test "renders errors when trying to enroll in own bounty", %{conn: conn, user: user} do
      bounty = insert(:bounty, owner: user, state: "open")

      conn = post(conn, bounty_enrollment_path(conn, :create, bounty))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end

    @tag :authenticated
    test "renders errors when already enrolled in bounty", %{conn: conn, user: user} do
      bounty = insert(:bounty, state: "open")

      Marketplace.create_enrollment(user.id, bounty.id)

      conn = post(conn, bounty_enrollment_path(conn, :create, bounty))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end

    test "renders errors when unauthenticated", %{conn: conn} do
      bounty = insert(:bounty)
      conn = post(conn, bounty_enrollment_path(conn, :create, bounty))
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end
  end
end
