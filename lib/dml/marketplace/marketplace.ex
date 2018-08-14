defmodule Dml.Marketplace do
  @behaviour Bodyguard.Policy

  import Ecto.Query, warn: false
  alias Dml.Accounts.User
  alias Dml.Marketplace.{Bounty, BountyStateMachine}
  alias Dml.Repo

  def list_bounties do
    Bounty |> Repo.all() |> Repo.preload(:owner)
  end

  def list_bounties_from_user(user) do
    Bounty |> where([b], b.owner_id == ^user.id) |> Repo.all()
  end

  def get_bounty!(id), do: Bounty |> Repo.get!(id) |> Repo.preload(:owner)

  def create_bounty(user_id, attrs \\ %{}) do
    %Bounty{owner_id: user_id}
    |> Bounty.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_bounty(%Bounty{} = bounty, attrs) do
    bounty
    |> Bounty.update_changeset(attrs)
    |> Repo.update()
  end

  def update_bounty_state(%Bounty{} = bounty, state) do
    Machinery.transition_to(bounty, BountyStateMachine, state)
  end

  def authorize(:update_bounty, %User{id: user_id}, %Bounty{owner_id: user_id}), do: true
  def authorize(_, _, _), do: false
end
