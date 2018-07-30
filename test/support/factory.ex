defmodule Dml.Factory do
  use ExMachina.Ecto, repo: Dml.Repo
  alias Faker.{Internet, Name, String}

  def user_factory do
    password = String.base64()

    %Dml.Accounts.User{
      email: Internet.email(),
      first_name: Name.first_name(),
      last_name: Name.last_name(),
      password: password,
      password_confirmation: password
    }
  end
end
