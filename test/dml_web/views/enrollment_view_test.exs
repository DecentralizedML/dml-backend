defmodule DmlWeb.EnrollmentViewTest do
  use DmlWeb.ConnCase, async: true
  alias DmlWeb.{EnrollmentView, UserView}

  test "index.json" do
    enrollment = insert(:enrollment)
    rendered_enrollments = EnrollmentView.render("index.json", %{enrollments: [enrollment]})

    assert rendered_enrollments == [enrollment_json(enrollment)]
  end

  test "show.json" do
    enrollment = insert(:enrollment)
    rendered_enrollment = EnrollmentView.render("show.json", %{enrollment: enrollment})

    assert rendered_enrollment == enrollment_json(enrollment)
  end

  test "enrollment.json" do
    enrollment = insert(:enrollment)
    rendered_enrollment = enrollment_json(enrollment)

    assert rendered_enrollment == %{
             id: enrollment.id,
             user: UserView.render("user.json", %{user: enrollment.user}),
             state: enrollment.state,
             rewarded: enrollment.rewarded,
             reward: enrollment.reward,
             rank: enrollment.rank
           }
  end

  defp enrollment_json(enrollment) do
    EnrollmentView.render("enrollment.json", %{enrollment: enrollment})
  end
end
