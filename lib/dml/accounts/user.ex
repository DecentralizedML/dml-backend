defmodule Dml.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :bio, :string, null: true
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    field :wallet_address, :string

    timestamps()
  end

  @doc false
  def create_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> validate_required([:email, :password, :password_confirmation])
  end

  @doc false
  def update_changeset(user, attrs), do: changeset(user, attrs)

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :first_name, :last_name, :password, :password_confirmation])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> unique_constraint(:email)
    |> put_password_hash
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}}
        -> put_change(changeset, :password_hash, hashpwsalt(pass))
      _ -> changeset
    end
  end
end
