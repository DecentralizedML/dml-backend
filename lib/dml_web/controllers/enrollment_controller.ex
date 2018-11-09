defmodule DmlWeb.EnrollmentController do
  use DmlWeb, :controller

  alias Dml.Marketplace
  alias Dml.Marketplace.{Enrollment, Enrollment}

  action_fallback(DmlWeb.FallbackController)

  def index(conn, %{"bounty_id" => bounty_id}) do
    current_user = current_user(conn)

    with bounty <- Marketplace.get_bounty!(bounty_id),
         :ok <- Bodyguard.permit(Marketplace, :list_enrollments, current_user, bounty),
         enrollments <- Marketplace.list_enrollments(bounty) do
      render(conn, "index.json", data: enrollments)
    end
  end

  def create(conn, %{"bounty_id" => bounty_id}) do
    current_user = current_user(conn)

    with bounty <- Marketplace.get_bounty!(bounty_id),
         :ok <- Bodyguard.permit(Marketplace, :enroll, current_user, bounty),
         {:ok, %Enrollment{} = enrollment} <- Marketplace.create_enrollment(current_user.id, bounty.id) do
      render(conn, "show.json", data: enrollment)
    end
  end
end
