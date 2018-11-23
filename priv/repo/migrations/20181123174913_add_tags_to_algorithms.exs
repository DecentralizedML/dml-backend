defmodule Dml.Repo.Migrations.AddTagsToAlgorithms do
  use Ecto.Migration

  def change do
    alter table("algorithms") do
      add(:tags, {:array, :string})
    end
  end
end
