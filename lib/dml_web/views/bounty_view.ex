defmodule DmlWeb.BountyView do
  use JSONAPI.View, type: "bounties"

  def fields do
    [:name, :description, :start_date, :end_date, :evaluation_date, :reward, :rewards, :state]
  end

  def relationships do
    [owner: {DmlWeb.UserView, :include}]
  end
end
