defmodule Dml.Repo.Migrations.AddRewardsToBounties do
  use Ecto.Migration

  def change do
    alter table("bounties") do
      add(:reward, :integer, default: 1)
      add(:rewards, {:array, :integer}, default: [])
    end
  end
end
