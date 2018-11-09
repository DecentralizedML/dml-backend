defmodule DmlWeb.UserView do
  use JSONAPI.View, type: "users", namespace: "/api"

  alias Dml.Accounts.User
  alias DmlWeb.ProfileImageUploader

  def fields do
    [:email, :first_name, :last_name, :profile_image, :wallet_address]
  end

  def profile_image(%User{profile_image: nil, profile_image_url: image}, _conn), do: image

  def profile_image(%User{profile_image: image} = user, _conn) do
    ProfileImageUploader.url({image, user}, :thumb)
  end
end
