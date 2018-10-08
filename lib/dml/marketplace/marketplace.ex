defmodule Dml.Marketplace do
  @behaviour Bodyguard.Policy

  import Ecto.Query, warn: false
  alias Dml.Accounts.User
  alias Dml.Marketplace.{Algorithm, Bounty, BountyStateMachine, Enrollment}
  alias Dml.Repo
  alias Ecto.Multi

  def list_bounties do
    Bounty |> Repo.all() |> Repo.preload(:owner)
  end

  def list_bounties_from_user(%User{} = user) do
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

  def reward_bounty(%Bounty{} = bounty, winners) do
    multi =
      winners
      |> Stream.with_index()
      |> Stream.map(fn {enrollment_id, rank} ->
        reward = Enum.at(bounty.rewards, rank)
        changeset = reward_enrollment_changeset(enrollment_id, rank, reward)
        Multi.update(Multi.new(), "reward_#{rank}", changeset)
      end)
      |> Enum.reduce(Multi.new(), &Multi.append/2)
      |> Multi.update(:reward, Bounty.update_state_changeset(bounty, %{state: "finished"}))

    Repo.transaction(multi)
  end

  defp reward_enrollment_changeset(enrollment_id, rank, reward) do
    %Enrollment{id: enrollment_id}
    |> Enrollment.reward_changeset(%{rewarded: true, rank: rank + 1, reward: reward})
  end

  def list_enrollments(%Bounty{} = bounty) do
    Enrollment |> where([e], e.bounty_id == ^bounty.id) |> Repo.all() |> Repo.preload([:user, :bounty])
  end

  def get_enrollment!(id), do: Enrollment |> Repo.get!(id) |> Repo.preload([:user, :bounty])

  def create_enrollment(user_id, bounty_id) do
    %Enrollment{bounty_id: bounty_id, user_id: user_id}
    |> Enrollment.create_changeset()
    |> Repo.insert()
    |> case do
      {:ok, item} -> {:ok, Repo.preload(item, [:user, :bounty])}
      {:error, error} -> {:error, error}
    end
  end

  def list_algorithms do
    Algorithm |> Repo.all() |> Repo.preload([:user, :enrollment, :bounty])
  end

  def list_algorithms_from_user(%User{} = user) do
    Algorithm |> where([a], a.user_id == ^user.id) |> Repo.all() |> Repo.preload([:enrollment, :bounty])
  end

  def list_approved_algorithms do
    Algorithm |> where([a], a.state == "approved") |> Repo.all() |> Repo.preload([:user, :enrollment, :bounty])
  end

  def get_algorithm!(id), do: Algorithm |> Repo.get!(id) |> Repo.preload([:user, :enrollment, :bounty])

  def create_algorithm(user_id, attrs \\ %{}) do
    %Algorithm{user_id: user_id}
    |> Algorithm.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_algorithm(%Algorithm{} = algorithm, attrs) do
    algorithm
    |> Algorithm.update_changeset(attrs)
    |> Repo.update()
  end

  def authorize(:update, %User{id: user_id}, %Bounty{owner_id: user_id}), do: true
  def authorize(:reward, %User{id: user_id}, %Bounty{owner_id: user_id, state: "closed"}), do: true
  def authorize(:update, %User{id: user_id}, %Algorithm{user_id: user_id}), do: true
  def authorize(:download, %User{id: user_id}, %Algorithm{user_id: user_id}), do: true
  def authorize(:enroll, %User{id: user_id}, %Bounty{owner_id: user_id}), do: false
  def authorize(:list_enrollments, %User{id: user_id}, %Bounty{owner_id: user_id}), do: true

  def authorize(:enroll, %User{} = user, %Bounty{state: "open"} = bounty) do
    # NOTE: Enrollment is possible only once
    Enrollment
    |> where([e], e.user_id == ^user.id and e.bounty_id == ^bounty.id)
    |> Repo.aggregate(:count, :id) == 0
  end

  def authorize(_, _, _), do: false
end
