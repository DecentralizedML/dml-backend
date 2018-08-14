defmodule Dml.Factory do
  use ExMachina.Ecto, repo: Dml.Repo
  alias Faker.{Commerce, Date, Internet, Lorem, Name, String}

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

  def bounty_factory do
    %Dml.Marketplace.Bounty{
      name: Commerce.product_name(),
      description: Lorem.paragraph(1),
      start_date: Date.forward(7),
      end_date: Date.forward(30),
      evaluation_date: Date.forward(30),
      owner: build(:user)
    }
  end
end
