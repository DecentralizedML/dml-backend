defmodule Dml.Marketplace.Algorithm do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}

  @create_attributes ~w(title description data_required device_fee)a
  @update_attributes ~w(title description data_required device_fee tags bounty_id enrollment_id)a

  schema "algorithms" do
    field(:title, :string)
    field(:description, :string)
    field(:data_required, :string)
    field(:device_fee, :integer, default: 1)
    field(:file, DmlWeb.Algorithm.Type)
    field(:state, :string, default: "pending")
    field(:tags, {:array, :string})

    timestamps()

    # Associations
    belongs_to(:user, Dml.Accounts.User, type: :binary_id)
    belongs_to(:enrollment, Dml.Marketplace.Enrollment, type: :binary_id)
    belongs_to(:bounty, Dml.Marketplace.Bounty, type: :binary_id)
  end

  def create_changeset(bounty, attrs) do
    bounty
    |> cast(attrs, @create_attributes)
    |> validate_title_and_description
    |> validate_device_fee
  end

  def update_changeset(bounty, attrs) do
    bounty
    |> cast(attrs, @update_attributes)
    |> cast_attachments(attrs, [:file])
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
