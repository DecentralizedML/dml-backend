defmodule DmlWeb.AlgorithmView do
  use JSONAPI.View, type: "algorithms"

  def fields do
    [:title, :description, :device_fee, :state]
  end

  def relationships do
    [user: {DmlWeb.UserView, :include}]
  end
end
