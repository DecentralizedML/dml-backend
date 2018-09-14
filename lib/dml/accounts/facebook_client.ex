defmodule Dml.Accounts.FacebookClient do
  use OAuth2.Strategy

  alias OAuth2.Client
  alias OAuth2.Strategy.AuthCode

  @authorization_scope "email"
  @user_fields "id,email,gender,link,locale,name,first_name,last_name,timezone,updated_time,verified"

  @client_defaults [
    strategy: __MODULE__,
    site: "https://graph.facebook.com",
    authorize_url: "https://www.facebook.com/v3.1/dialog/oauth",
    token_url: "/v3.1/oauth/access_token",
    token_method: :get
  ]

  # Public API

  def client(opts \\ []) do
    opts =
      @client_defaults
      |> Keyword.merge(config())
      |> Keyword.merge(opts)

    Client.new(opts)
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
    |> put_param(:client_secret, client.client_secret)
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end

  def get_user(client, query_params \\ []) do
    case Client.get(client, user_path(client, query_params)) do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        {:error, "Unauthorized"}

      {:ok, %OAuth2.Response{status_code: status_code, body: user}} when status_code in 200..399 ->
        {:ok, user}

      {:error, %OAuth2.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  # Helpers

  def user_path(client, query_params \\ []) do
    "/me?" <> user_query(client.token.access_token, query_params)
  end

  defp user_query(access_token, query_params) do
    custom_params = Enum.into(query_params, %{})

    %{}
    |> Map.put(:fields, @user_fields)
    |> Map.put(:appsecret_proof, appsecret_proof(access_token))
    |> Map.merge(custom_params)
    |> Enum.filter(fn {_, v} -> v != nil and v != "" end)
    |> URI.encode_query()
  end

  def appsecret_proof(access_token) do
    access_token
    |> hmac(:sha256, Keyword.get(config(), :client_secret))
    |> Base.encode16(case: :lower)
  end

  defp hmac(data, type, key) do
    :crypto.hmac(type, key, data)
  end

  defp config do
    Application.get_env(:dml, Dml.Accounts.FacebookClient)
  end
end
