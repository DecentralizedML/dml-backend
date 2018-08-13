defmodule Dml.Marketplace do
  @moduledoc """
  The Marketplace context.
  """

  import Ecto.Query, warn: false
  alias Dml.Marketplace.Bounty
  alias Dml.Repo

  @doc """
  Returns the list of bounties.

  ## Examples

      iex> list_bounties()
      [%Bounty{}, ...]

  """
  def list_bounties do
    Repo.all(Bounty)
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
  def get_bounty!(id), do: Repo.get!(Bounty, id)

  @doc """
  Creates a bounty.

  ## Examples

      iex> create_bounty(%{field: value})
      {:ok, %Bounty{}}

      iex> create_bounty(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bounty(attrs \\ %{}) do
    %Bounty{}
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
  Deletes a Bounty.

  ## Examples

      iex> delete_bounty(bounty)
      {:ok, %Bounty{}}

      iex> delete_bounty(bounty)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bounty(%Bounty{} = bounty) do
    Repo.delete(bounty)
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
end
