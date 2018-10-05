defmodule DmlWeb.EnrollmentView do
  use DmlWeb, :view
  alias DmlWeb.{EnrollmentView, UserView}

  def render("index.json", %{enrollments: enrollments}) do
    render_many(enrollments, EnrollmentView, "enrollment.json")
  end

  def render("show.json", %{enrollment: enrollment}) do
    render_one(enrollment, EnrollmentView, "enrollment.json")
  end

  def render("enrollment.json", %{enrollment: enrollment}) do
    %{
      id: enrollment.id,
      user: UserView.render("user.json", %{user: enrollment.user}),
      state: enrollment.state,
      rewarded: enrollment.rewarded,
      reward: enrollment.reward,
      rank: enrollment.rank
    }
  end
end
