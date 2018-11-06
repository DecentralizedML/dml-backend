defmodule Dml.Accounts.User do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}

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
    field(:new, :boolean, default: false, virtual: true)

    timestamps()

    # Associations
    has_many(:bounties, Dml.Marketplace.Bounty, foreign_key: :owner_id)
  end

  def create_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :password_confirmation])
    |> validate_email
    |> validate_password
  end

  def create_from_oauth_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :first_name, :last_name, :google_uid, :facebook_uid])
    |> validate_email
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name])
    |> cast_attachments(attrs, [:profile_image])
    |> validate_first_and_last_name
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

  defp validate_first_and_last_name(changeset) do
    changeset
    |> validate_required([:first_name, :last_name], trim: true)
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
