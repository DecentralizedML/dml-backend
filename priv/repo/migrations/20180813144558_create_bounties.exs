defmodule Dml.Repo.Migrations.CreateBounties do
  use Ecto.Migration

  def change do
    create table(:bounties, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      add(:description, :text)
      add(:start_date, :date, null: true)
      add(:end_date, :date, null: true)
      add(:evaluation_date, :date, null: true)
      add(:state, :string, default: "pending")
      add(:owner_id, references(:users, on_delete: :nothing, type: :uuid))

      timestamps()
    end

    create(index(:bounties, [:owner_id]))
  end
end
