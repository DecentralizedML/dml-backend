defmodule Dml.Accounts.GoogleClient do
  use OAuth2.Strategy

  alias OAuth2.Client
  alias OAuth2.Strategy.AuthCode

  @authorization_scope "https://www.googleapis.com/auth/userinfo.email"
  @user_endpoint "https://www.googleapis.com/plus/v1/people/me/openIdConnect"

  defp config do
    [
      strategy: __MODULE__,
      client_id: System.get_env("GOOGLE_CLIENT_ID"),
      client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
      redirect_uri: System.get_env("GOOGLE_REDIRECT_URI"),
      site: "https://accounts.google.com",
      authorize_url: "/o/oauth2/auth",
      token_url: "/o/oauth2/token"
    ]
  end

  # Public API

  def client(params \\ []) do
    params
    |> Keyword.merge(config())
    |> Client.new()
  end

  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> Client.authorize_url!(params)
  end

  def get_token!(params \\ [], opts \\ []) do
    opts
    |> client
    |> Client.get_token!(params)
  end

  # Strategy Callbacks

  def authorize_url(client, params \\ %{}) do
    AuthCode.authorize_url(client, Keyword.merge(params, scope: @authorization_scope))
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end

  def get_user(client, _query_params \\ []) do
    case Client.get(client, @user_endpoint) do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        {:error, "Unauthorized"}

      {:ok, %OAuth2.Response{status_code: status_code, body: user}} when status_code in 200..399 ->
        {:ok, user}

      {:error, %OAuth2.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
