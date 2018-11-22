defmodule Dml.Accounts.User do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}

  @genders ["male", "female", "other"]
  @education_levels ["primary", "secondary", "associates", "bachelors", "masters", "doctorate"]
  @permissions ["sms", "photo", "twitter"]

  @create_attributes [:email, :password, :password_confirmation]
  @create_oauth_attributes [:email, :first_name, :last_name, :google_uid, :facebook_uid, :profile_image_url]
  @update_attributes [
    :first_name,
    :last_name,
    :wallet_address,
    :encrypted_seedphrase_with_password,
    :encrypted_seedphrase_with_answer1,
    :encrypted_seedphrase_with_answer2,
    :security_question1,
    :security_answer1,
    :security_question2,
    :security_answer2,
    :country,
    :date_of_birth,
    :gender,
    :education_level,
    :permissions
  ]

  schema "users" do
    field(:email, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:bio, :string, null: true)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    field(:password_hash, :string)
    field(:wallet_address, :string)
    field(:google_uid, :string)
    field(:facebook_uid, :string)
    field(:profile_image, DmlWeb.ProfileImageUploader.Type)
    field(:profile_image_url, :string)
    field(:encrypted_seedphrase_with_password, :string)
    field(:encrypted_seedphrase_with_answer1, :string)
    field(:encrypted_seedphrase_with_answer2, :string)
    field(:security_question1, :string)
    field(:security_answer1, :string)
    field(:security_question2, :string)
    field(:security_answer2, :string)
    field(:country, :string)
    field(:date_of_birth, :date)
    field(:gender, :string)
    field(:education_level, :string)
    field(:permissions, {:array, :string})
    field(:new, :boolean, default: false, virtual: true)

    timestamps()

    # Associations
    has_many(:bounties, Dml.Marketplace.Bounty, foreign_key: :owner_id)
  end

  def create_changeset(user, attrs) do
    user
    |> cast(attrs, @create_attributes)
    |> validate_email
    |> validate_password
  end

  def create_from_oauth_changeset(user, attrs) do
    user
    |> cast(attrs, @create_oauth_attributes)
    |> validate_email
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, @update_attributes)
    |> cast_attachments(attrs, [:profile_image])
    |> validate_first_and_last_name
    |> validate_eth_address(:wallet_address)
    |> validate_security_answers
    |> validate_country
    |> validate_inclusion(:gender, @genders)
    |> validate_inclusion(:education_level, @education_levels)
    |> validate_subset(:permissions, @permissions)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email], trim: true)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password, :password_confirmation])
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> put_password_hash
  end

  defp validate_eth_address(changeset, field) do
    changeset
    |> validate_format(field, ~r/^(0x)?[0-9a-f]{40}$/i)
  end

  defp validate_first_and_last_name(changeset) do
    changeset
    |> validate_required([:first_name, :last_name], trim: true)
  end

  defp validate_security_answers(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{security_answer1: answer1, security_answer2: answer2}} ->
        changeset
        |> put_change(:security_answer1, hashpwsalt(answer1))
        |> put_change(:security_answer2, hashpwsalt(answer2))

      %Ecto.Changeset{valid?: true, changes: %{security_answer1: answer1}} ->
        changeset
        |> put_change(:security_answer1, hashpwsalt(answer1))

      _ ->
        changeset
    end
  end

  defp validate_country(changeset) do
    validate_change(changeset, :country, fn _, country ->
      case Countries.exists?(:alpha2, country) do
        true -> []
        false -> [{:country, "is invalid"}]
      end
    end)
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, hashpwsalt(pass))

      _ ->
        changeset
    end
  end
end
