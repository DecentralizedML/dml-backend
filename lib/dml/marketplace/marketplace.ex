defmodule Dml.Marketplace do
  @behaviour Bodyguard.Policy

  @moduledoc """
  The Marketplace context.
  """

  import Ecto.Query, warn: false
  alias Dml.Accounts.User
  alias Dml.Marketplace.Bounty
  alias Dml.Repo

  @doc """
  Returns the list of bounties.

  ## Examples

      iex> list_bounties()
      [%Bounty{}, ...]

  """
  def list_bounties do
    Bounty |> Repo.all() |> Repo.preload(:owner)
  end

  def list_bounties_from_user(user) do
    Bounty |> where([b], b.owner_id == ^user.id) |> Repo.all()
  end

  @doc """
  Gets a single bounty.

  Raises `Ecto.NoResultsError` if the Bounty does not exist.

  ## Examples

      iex> get_bounty!(123)
      %Bounty{}

      iex> get_bounty!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bounty!(id), do: Bounty |> Repo.get!(id) |> Repo.preload(:owner)

  @doc """
  Creates a bounty.

  ## Examples

      iex> create_bounty(user, %{field: value})
      {:ok, %Bounty{}}

      iex> create_bounty(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bounty(user_id, attrs \\ %{}) do
    %Bounty{owner_id: user_id}
    |> Bounty.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bounty.

  ## Examples

      iex> update_bounty(bounty, %{field: new_value})
      {:ok, %Bounty{}}

      iex> update_bounty(bounty, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bounty(%Bounty{} = bounty, attrs) do
    bounty
    |> Bounty.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bounty changes.

  ## Examples

      iex> change_bounty(bounty)
      %Ecto.Changeset{source: %Bounty{}}

  """
  def change_bounty(%Bounty{} = bounty) do
    Bounty.changeset(bounty, %{})
  end

  def authorize(:update_bounty, %User{id: user_id}, %Bounty{owner_id: user_id}), do: true
  def authorize(_, _, _), do: false
end
