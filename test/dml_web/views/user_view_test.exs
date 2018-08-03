defmodule DmlWeb.UserViewTest do
  use DmlWeb.ConnCase, async: true
  alias DmlWeb.UserView

  defp user_json(user) do
    UserView.render("user.json", %{user: user})
  end

  test "user.json" do
    user = insert(:user)
    rendered_user = user_json(user)

    assert rendered_user == %{
             id: user.id,
             email: user.email,
             first_name: user.first_name,
             last_name: user.last_name,
             wallet_address: user.wallet_address
           }
  end

  test "index.json" do
    user = insert(:user)
    rendered_users = UserView.render("index.json", %{users: [user]})

    assert rendered_users == [user_json(user)]
  end

  test "show.json" do
    user = insert(:user)
    rendered_user = UserView.render("show.json", %{user: user})

    assert rendered_user == user_json(user)
  end

  test "jwt.json" do
    user = insert(:user)
    token = "123"
    rendered_token = UserView.render("jwt.json", %{jwt: token, user: user})

    assert rendered_token == %{jwt: token} |> Enum.into(user_json(user))
  end
end
