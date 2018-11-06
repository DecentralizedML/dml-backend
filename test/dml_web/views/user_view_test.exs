defmodule DmlWeb.UserViewTest do
  use DmlWeb.ConnCase, async: true
  alias Dml.Repo
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
             profile_image: UserView.profile_image(user),
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

  describe "profile_image/1" do
    test "user with uploaded image" do
      user = build(:user, profile_image_url: "hello.jpg") |> with_profile_image |> Repo.insert!()
      assert UserView.profile_image(user) =~ ~r{/uploads/profile_images/[A-F0-9]+_thumb\.jpg}
    end

    test "user with image URL" do
      user = insert(:user, profile_image_url: "hello.jpg")
      assert UserView.profile_image(user) == "hello.jpg"
    end

    test "user without image" do
      user = insert(:user)
      assert UserView.profile_image(user) == nil
    end
  end
end
