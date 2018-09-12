defmodule Dml.Repo.Migrations.AddOAuthFields do
  use Ecto.Migration

  def change do
    alter table("users") do
      add(:google_uid, :text)
      add(:facebook_uid, :text)
    end
  end
end
