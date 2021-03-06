defmodule Dml.Marketplace.Bounty do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}

  schema "bounties" do
    field(:name, :string)
    field(:description, :string)
    field(:start_date, :date, null: true)
    field(:end_date, :date, null: true)
    field(:evaluation_date, :date, null: true)
    field(:state, :string, default: "pending")
    field(:reward, :integer, default: 1)
    field(:rewards, {:array, :integer}, default: [1])

    timestamps()

    # Associations
    belongs_to(:owner, Dml.Accounts.User, type: :binary_id)
  end

  def create_changeset(bounty, attrs) do
    bounty
    |> cast(attrs, [:name, :description, :start_date, :end_date, :evaluation_date, :reward, :rewards])
    |> validate_name_and_description
    |> validate_reward
  end

  def update_changeset(bounty, attrs), do: create_changeset(bounty, attrs)

  def update_state_changeset(bounty, attrs) do
    bounty
    |> cast(attrs, [:state])
    |> validate_required([:state])
    |> validate_inclusion(:state, ["pending", "open", "closed", "finished"])
  end

  defp validate_name_and_description(changeset) do
    changeset
    |> validate_required([:name, :description], trim: true)
  end

  defp validate_reward(changeset) do
    rewards = changeset |> get_change(:rewards, []) |> Enum.sum()

    changeset
    |> validate_number(:reward, greater_than_or_equal_to: 1)
    |> validate_number(:reward, equal_to: rewards)
  end
end
