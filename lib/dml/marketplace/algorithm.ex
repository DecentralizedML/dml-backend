defmodule Dml.Marketplace.Algorithm do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}

  schema "algorithms" do
    field(:data_required, :string)
    field(:description, :string)
    field(:device_fee, :integer, default: 1)
    field(:state, :string, default: "pending")
    field(:title, :string)

    timestamps()

    # Associations
    belongs_to(:user, Dml.Accounts.User, type: :binary_id)
    belongs_to(:enrollment, Dml.Marketplace.Enrollment, type: :binary_id)
    belongs_to(:bounty, Dml.Marketplace.Bounty, type: :binary_id)
  end

  def changeset(algorithm, attrs) do
    algorithm
    |> cast(attrs, [:title, :description, :data_required, :device_fee, :state])
    |> validate_required([:title, :description, :data_required, :device_fee, :state])
  end
end
