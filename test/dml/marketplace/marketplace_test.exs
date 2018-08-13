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
      assert {:ok, %Bounty{} = bounty} = Marketplace.create_bounty(@valid_attrs)
      assert bounty.name == @valid_attrs[:name]
    end

    test "create_bounty/1 with invalid data returns error changeset" do
      assert {:error, changeset} = Marketplace.create_bounty(@invalid_attrs)
      assert "can't be blank" in errors_on(changeset).name
    end

    test "update_bounty/2 with valid data (only name) updates the bounty" do
      bounty = insert(:bounty)
      assert {:ok, bounty} = Marketplace.update_bounty(bounty, @update_attrs)
      assert %Bounty{} = bounty
      assert bounty.name == @update_attrs[:name]
    end

    test "update_bounty/2 with invalid data returns error changeset" do
      bounty = insert(:bounty)
      assert {:error, %Ecto.Changeset{}} = Marketplace.update_bounty(bounty, @invalid_attrs)
    end

    test "delete_bounty/1 deletes the bounty" do
      bounty = insert(:bounty)
      assert {:ok, %Bounty{}} = Marketplace.delete_bounty(bounty)
      assert_raise Ecto.NoResultsError, fn -> Marketplace.get_bounty!(bounty.id) end
    end

    test "change_bounty/1 returns a bounty changeset" do
      bounty = insert(:bounty)
      assert %Ecto.Changeset{} = Marketplace.change_bounty(bounty)
    end
  end
end
