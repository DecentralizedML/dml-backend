defmodule DmlWeb.EnrollmentView do
  use JSONAPI.View, type: "enrollments"

  def fields do
    [:state, :rewarded, :reward, :rank]
  end

  def relationships do
    [user: {DmlWeb.UserView, :include}]
  end
end
