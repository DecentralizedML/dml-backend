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

    timestamps()

    # Associations
    belongs_to(:owner, Dml.Accounts.User, type: :binary_id)
  end

  def changeset(bounty, attrs) do
    bounty
    |> cast(attrs, [:name, :description, :state, :start_date, :end_date, :evaluation_date])
    |> validate_required([:name, :description], trim: true)
  end
end
