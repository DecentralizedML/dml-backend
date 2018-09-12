defmodule DmlWeb.AuthControllerTest do
  use DmlWeb.ConnCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Dml.Guardian
  alias ExVCR.Config

  setup %{conn: conn} do
    Config.cassette_library_dir("test/fixtures/vcr_cassettes")

    Config.filter_request_headers("authorization")
    Config.filter_sensitive_data(System.get_env("GOOGLE_CLIENT_ID"), "<GOOGLE_CLIENT_ID>")
    Config.filter_sensitive_data(System.get_env("GOOGLE_CLIENT_SECRET"), "<GOOGLE_CLIENT_SECRET>")

    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  @google_auth_params %{
    "provider" => "google",
    "code" => "4/WACGmwPZcbhE0PZ48Uzdq_o1dwB6j_NNA4HQKEVy17BOUzABdXdYit7g78TP2HGuh1_FltHGeKmjpZWrkY-ADvc",
    "uid" => "108724422355747527461"
  }

  describe "create user (Google)" do
    test "renders JWT when data is valid", %{conn: conn} do
      params = Map.take(@google_auth_params, ["provider", "code"])

      conn =
        use_cassette "google_valid_oauth" do
          get(conn, auth_path(conn, :callback, "google"), params)
        end

      assert %{"jwt" => token} = json_response(conn, 201)

      {:ok, claims} = Guardian.decode_and_verify(token)
      {:ok, user} = Guardian.resource_from_claims(claims)

      assert user.email == "thiago.belem.web@gmail.com"
      assert user.first_name == "Thiago"
      assert user.last_name == "Belem"
      assert user.google_uid == @google_auth_params["uid"]
    end
  end

  describe "login user (Google)" do
    test "renders JWT when data is valid", %{conn: conn} do
      user = insert(:user, email: "thiago.belem.web@gmail.com", google_uid: @google_auth_params["uid"])
      id = user.id

      params = Map.take(@google_auth_params, ["provider", "code"])

      conn =
        use_cassette "google_valid_oauth" do
          get(conn, auth_path(conn, :callback, "google"), params)
        end

      assert %{"jwt" => token, "id" => ^id} = json_response(conn, 201)
    end
  end
end
