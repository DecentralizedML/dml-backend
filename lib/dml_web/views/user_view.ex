defmodule DmlWeb.UserView do
  use DmlWeb, :view
  alias DmlWeb.UserView

  def render("index.json", %{users: users}) do
    render_many(users, UserView, "user.json")
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("jwt.json", %{jwt: jwt}) do
    %{jwt: jwt}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email,
      wallet_address: user.wallet_address}
  end
end
