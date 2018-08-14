defmodule Dml.BountyStateMachineTest do
  use Dml.DataCase

  alias Dml.Marketplace
  alias Dml.Marketplace.{Bounty, BountyStateMachine}

  describe "pending state" do
    setup do
      %{bounty: insert(:bounty, state: "pending")}
    end

    test "is the initial state" do
      user = insert(:user)
      {:ok, bounty} = Marketplace.create_bounty(user.id, %{name: "Test", description: "Test"})
      assert bounty.state == "pending"
    end

    test "can transition to open", %{bounty: bounty} do
      assert {:ok, %Bounty{state: "open"}} = Machinery.transition_to(bounty, BountyStateMachine, "open")
    end

    test "cannot transition to closed", %{bounty: bounty} do
      assert {:error, _} = Machinery.transition_to(bounty, BountyStateMachine, "closed")
    end

    test "can transition to finished", %{bounty: bounty} do
      assert {:ok, %Bounty{state: "finished"}} = Machinery.transition_to(bounty, BountyStateMachine, "finished")
    end
  end

  describe "open state" do
    setup do
      %{bounty: insert(:bounty, state: "open")}
    end

    test "cannot transition to pending", %{bounty: bounty} do
      assert {:error, _} = Machinery.transition_to(bounty, BountyStateMachine, "pending")
    end

    test "can transition to closed", %{bounty: bounty} do
      assert {:ok, %Bounty{state: "closed"}} = Machinery.transition_to(bounty, BountyStateMachine, "closed")
    end

    test "can transition to finished", %{bounty: bounty} do
      assert {:ok, %Bounty{state: "finished"}} = Machinery.transition_to(bounty, BountyStateMachine, "finished")
    end
  end

  describe "closed state" do
    setup do
      %{bounty: insert(:bounty, state: "closed")}
    end

    test "cannot transition to pending or open", %{bounty: bounty} do
      assert {:error, _} = Machinery.transition_to(bounty, BountyStateMachine, "pending")
      assert {:error, _} = Machinery.transition_to(bounty, BountyStateMachine, "open")
    end

    test "can transition to finished", %{bounty: bounty} do
      assert {:ok, %Bounty{state: "finished"}} = Machinery.transition_to(bounty, BountyStateMachine, "finished")
    end
  end

  describe "finished state" do
    setup do
      %{bounty: insert(:bounty, state: "closed")}
    end

    test "cannot transition to pending, open or closed", %{bounty: bounty} do
      assert {:error, _} = Machinery.transition_to(bounty, BountyStateMachine, "pending")
      assert {:error, _} = Machinery.transition_to(bounty, BountyStateMachine, "open")
      assert {:error, _} = Machinery.transition_to(bounty, BountyStateMachine, "closed")
    end
  end
end
