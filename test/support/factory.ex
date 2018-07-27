defmodule Dml.Factory do
  use ExMachina.Ecto, repo: Dml.Repo

  def user_factory do
    email = random_string(10)
    password = random_string(20)

    %Dml.Accounts.User{
      email: "user_#{email}@kyokan.io",
      password: password,
      password_confirmation: password
    }
  end

  defp random_string(length) do
    length
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64
    |> binary_part(0, length)
  end
end
