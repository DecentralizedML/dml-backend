defmodule Dml.Repo.Migrations.CreateEnrollments do
  use Ecto.Migration

  def change do
    create table(:enrollments, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:user_id, references(:users, on_delete: :nothing, type: :uuid))
      add(:bounty_id, references(:bounties, on_delete: :nothing, type: :uuid))
      # add(:alogrithm_id, references(:algorithms, on_delete: :nothing, type: :uuid))
      add(:state, :string, default: "pending")
      add(:rewarded, :boolean, default: false, null: false)
      add(:reward, :integer, null: true)
      add(:rank, :integer, null: true)

      timestamps()
    end

    create(index(:enrollments, [:user_id]))
    create(index(:enrollments, [:bounty_id]))
    # create(index(:enrollments, [:algoritm_id]))
  end
end
