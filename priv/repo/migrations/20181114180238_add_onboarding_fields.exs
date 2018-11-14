defmodule Dml.Repo.Migrations.AddOnboardingFields do
  use Ecto.Migration

  def change do
    alter table("users") do
      add(:private_key, :binary)
      add(:security_question1, :string)
      add(:security_answer1, :string)
      add(:security_question2, :string)
      add(:security_answer2, :string)
    end
  end
end
