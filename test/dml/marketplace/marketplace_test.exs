defmodule Dml.MarketplaceTest do
  use Dml.DataCase

  alias Dml.Marketplace

  describe "bounties" do
    alias Dml.Marketplace.Bounty

    @valid_attrs params_for(:bounty)
    @update_attrs params_for(:bounty) |> Map.take([:name, :description])
    @invalid_attrs params_for(:bounty, name: "")

    test "list_bounties/0 returns all bounties" do
      bounty = insert(:bounty)
      bounties = Marketplace.list_bounties()

      assert Enum.count(bounties) == 1
      assert has_element_by_id(bounties, %{id: bounty.id})
    end

    test "get_bounty!/1 returns the bounty with given id" do
      bounty = insert(:bounty)

      assert Marketplace.get_bounty!(bounty.id).id == bounty.id
    end

    test "create_bounty/1 with valid data creates a bounty" do
      user = insert(:user)
      assert {:ok, %Bounty{} = bounty} = Marketplace.create_bounty(user.id, @valid_attrs)
      assert bounty.name == @valid_attrs[:name]
      assert bounty.owner_id == user.id
    end

    test "create_bounty/1 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, changeset} = Marketplace.create_bounty(user, @invalid_attrs)
      assert "can't be blank" in errors_on(changeset).name
    end

    test "update_bounty/2 with valid data (only name) updates the bounty" do
      bounty = insert(:bounty)
      assert {:ok, %Bounty{} = bounty} = Marketplace.update_bounty(bounty, @update_attrs)
      assert bounty.name == @update_attrs[:name]
    end

    test "update_bounty/2 with invalid data returns error changeset" do
      bounty = insert(:bounty)
      assert {:error, %Ecto.Changeset{}} = Marketplace.update_bounty(bounty, @invalid_attrs)
    end

    test "update_bounty_state/2 with valid state updates the bounty" do
      bounty = insert(:bounty)
      assert bounty.state == "pending"
      assert {:ok, %Bounty{} = bounty} = Marketplace.update_bounty_state(bounty, "open")

      bounty = Marketplace.get_bounty!(bounty.id)
      assert bounty.state == "open"
    end
  end

  describe "enrollments" do
    alias Dml.Marketplace.Enrollment

    setup do
      %{bounty: insert(:bounty)}
    end

    test "list_enrollments/0 returns all enrollments" do
      enrollment = insert(:enrollment)
      enrollments = Marketplace.list_enrollments()

      assert Enum.count(enrollments) == 1
      assert has_element_by_id(enrollments, %{id: enrollment.id})
    end

    test "get_enrollment!/1 returns the enrollment with given id" do
      enrollment = insert(:enrollment)

      assert Marketplace.get_enrollment!(enrollment.id).id == enrollment.id
    end

    test "create_enrollment/1 with valid data creates a enrollment", %{bounty: bounty} do
      user = insert(:user)

      assert {:ok, %Enrollment{} = enrollment} = Marketplace.create_enrollment(user.id, bounty.id)
      assert enrollment.user_id == user.id
      assert enrollment.bounty_id == bounty.id
      assert enrollment.state == "pending"
      assert enrollment.rewarded == false
    end

    test "create_enrollment/1 with invalid data returns error changeset", %{bounty: bounty} do
      assert {:error, changeset} = Marketplace.create_enrollment(nil, bounty.id)
      assert "can't be blank" in errors_on(changeset).user_id
    end
  end
end
