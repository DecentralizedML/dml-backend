defmodule DmlWeb.UserView do
  use DmlWeb, :view
  alias Dml.Accounts.User
  alias DmlWeb.ProfileImageUploader
  alias DmlWeb.UserView

  def render("index.json", %{users: users}) do
    render_many(users, UserView, "user.json")
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("jwt.json", %{user: user, jwt: jwt}) do
    %{jwt: jwt} |> Enum.into(render_one(user, UserView, "user.json"))
  end

  def render("user.json", %{user: %Ecto.Association.NotLoaded{}}), do: nil
  def render("user.json", %{user: nil}), do: nil

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      profile_image: profile_image(user),
      wallet_address: user.wallet_address
    }
  end

  def profile_image(%User{profile_image: nil, profile_image_url: image}), do: image

  def profile_image(%User{profile_image: image} = user) do
    ProfileImageUploader.url({image, user}, :original)
  end
end
