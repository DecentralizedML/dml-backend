defmodule Dml.Repo.Migrations.AddProfileImageToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add(:profile_image, :string)
      add(:profile_image_url, :string)
    end
  end
end
