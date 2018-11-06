defmodule Dml.Repo.Migrations.AddDownloadsToAlgorithms do
  use Ecto.Migration

  def change do
    alter table("algorithms") do
      add(:downloads, :integer, default: 1)
    end
  end
end
