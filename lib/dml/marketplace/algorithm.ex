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

  def create_changeset(bounty, attrs) do
    bounty
    |> cast(attrs, [:title, :description, :data_required, :device_fee])
    |> validate_title_and_description
    |> validate_device_fee
  end

  def update_changeset(bounty, attrs) do
    bounty
    |> cast(attrs, [:title, :description, :data_required, :device_fee, :bounty_id, :enrollment_id])
    |> validate_title_and_description
    |> validate_device_fee
  end

  defp validate_title_and_description(changeset) do
    changeset
    |> validate_required([:title, :description], trim: true)
  end

  defp validate_device_fee(changeset) do
    changeset
    |> validate_number(:device_fee, greater_than_or_equal_to: 1)
  end
end
