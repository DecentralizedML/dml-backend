defmodule Dml.Repo.Migrations.AddAlgorithmFileField do
  use Ecto.Migration

  def change do
    alter table("algorithms") do
      add(:file, :string)
    end
  end
end
