defmodule Dml.Accounts.GoogleClient do
  use OAuth2.Strategy

  alias OAuth2.Client
  alias OAuth2.Strategy.AuthCode

  @authorization_scope "https://www.googleapis.com/auth/userinfo.email"
  @user_endpoint "https://www.googleapis.com/plus/v1/people/me/openIdConnect"
  @user_fields ["sub", "email", "given_name", "family_name", "picture"]

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

  def client do
    Client.new(config())
  end

  def authorization_url(params \\ []) do
    Client.authorize_url!(client(), params)
  end

  def get_token(params \\ [], _headers \\ []) do
    Client.get_token!(client(), Keyword.merge(params, client_secret: client().client_secret))
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

  def get_user(client, _params \\ %{}) do
    %{body: user, status_code: _status} = Client.get!(client, @user_endpoint)
    {:ok, Map.take(user, @user_fields)}
  end
end
