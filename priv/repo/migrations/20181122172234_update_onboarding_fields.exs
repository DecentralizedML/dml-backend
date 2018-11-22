defmodule Dml.Repo.Migrations.UpdateOnboardingFields do
  use Ecto.Migration

  def change do
    alter table("users") do
      remove(:private_key)
      add(:encrypted_seedphrase_with_password, :string)
      add(:encrypted_seedphrase_with_answer1, :string)
      add(:encrypted_seedphrase_with_answer2, :string)
      add(:country, :string, length: 2)
      add(:date_of_birth, :date)
      # male/female/other
      add(:gender, :string)
      # primary/secondary/associates/bachelors/masters/doctorate
      add(:education_level, :string)
      # sms/photo/twitter
      add(:permissions, {:array, :string})
    end
  end
end
