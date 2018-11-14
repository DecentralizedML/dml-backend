defmodule Dml.Repo.Migrations.AddProfileColumsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:first_name, :string)
      add(:last_name, :string)
      add(:bio, :text, null: true)
    end
  end
end
