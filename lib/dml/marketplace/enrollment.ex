defmodule Dml.Marketplace.Enrollment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}

  schema "enrollments" do
    field(:state, :string, default: "pending")
    field(:reward, :integer, null: false)
    field(:rewarded, :boolean, default: false, null: false)
    field(:rank, :integer, null: false)

    timestamps()

    # Associations
    belongs_to(:user, Dml.Accounts.User, type: :binary_id)
    belongs_to(:bounty, Dml.Marketplace.Bounty, type: :binary_id)
    # belongs_to(:algorithm, Dml.Marketplace.Algorithm, type: :binary_id)
  end

  def create_changeset(enrollment, attrs \\ %{}) do
    enrollment
    |> cast(attrs, [])
    |> validate_required([:user_id, :bounty_id])
  end
end
