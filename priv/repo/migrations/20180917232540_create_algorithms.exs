defmodule Dml.Repo.Migrations.CreateAlgorithms do
  use Ecto.Migration

  def change do
    create table(:algorithms, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:title, :string)
      add(:description, :text)
      add(:data_required, :string)
      add(:device_fee, :integer, default: 1)
      add(:state, :string, default: "pending")
      add(:user_id, references(:users, on_delete: :nothing, type: :uuid))
      add(:enrollment_id, references(:enrollments, on_delete: :nothing, type: :uuid), null: true)
      add(:bounty_id, references(:bounties, on_delete: :nothing, type: :uuid), null: true)

      timestamps()
    end

    create(index(:algorithms, [:user_id]))
    create(unique_index(:algorithms, [:enrollment_id]))
    create(index(:algorithms, [:bounty_id]))
  end
end
