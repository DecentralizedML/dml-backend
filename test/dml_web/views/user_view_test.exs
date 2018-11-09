defmodule DmlWeb.UserViewTest do
  use DmlWeb.ConnCase, async: true
  alias Dml.Repo
  alias DmlWeb.UserView

  describe "profile_image/1" do
    test "user with uploaded image", %{conn: conn} do
      user = build(:user, profile_image_url: "hello.jpg") |> with_profile_image |> Repo.insert!()
      assert UserView.profile_image(user, conn) =~ ~r{/uploads/profile_images/[A-F0-9]+_thumb\.jpg}
    end

    test "user with image URL", %{conn: conn} do
      user = insert(:user, profile_image_url: "hello.jpg")
      assert UserView.profile_image(user, conn) == "hello.jpg"
    end

    test "user without image", %{conn: conn} do
      user = insert(:user)
      assert UserView.profile_image(user, conn) == nil
    end
  end
end
