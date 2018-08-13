defmodule Dml.Marketplace.Bounty do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}

  schema "bounties" do
    field(:description, :string)
    field(:end_date, :date)
    field(:evaluation_date, :date)
    field(:name, :string)
    field(:start_date, :date)
    field(:status, :string)

    timestamps()

    # Associations
    belongs_to(:owner, Dml.Accounts.User, type: :binary_id)
  end

  def changeset(bounty, attrs) do
    bounty
    |> cast(attrs, [:name])
    |> validate_required([:name], trim: true)
  end
end
