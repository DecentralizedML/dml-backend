defmodule DmlWeb.AuthControllerTest do
  use DmlWeb.ConnCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Dml.Guardian
  alias ExVCR.Config

  setup %{conn: conn} do
    Config.cassette_library_dir("test/fixtures/vcr_cassettes")

    Config.filter_request_headers("authorization")

    config = Application.get_env(:dml, Dml.Accounts.GoogleClient)
    Config.filter_sensitive_data(config[:client_id], "<GOOGLE_CLIENT_ID>")
    Config.filter_sensitive_data(config[:client_secret], "<GOOGLE_CLIENT_SECRET>")

    config = Application.get_env(:dml, Dml.Accounts.FacebookClient)
    Config.filter_sensitive_data(config[:client_id], "<FACEBOOK_CLIENT_ID>")
    Config.filter_sensitive_data(config[:client_secret], "<FACEBOOK_CLIENT_SECRET>")

    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  @google_auth_params %{
    "provider" => "google",
    "code" => "4/WACGmwPZcbhE0PZ48Uzdq_o1dwB6j_NNA4HQKEVy17BOUzABdXdYit7g78TP2HGuh1_FltHGeKmjpZWrkY-ADvc",
    "id" => "108724422355747527461"
  }

  @facebook_auth_params %{
    "provider" => "facebook",
    "code" =>
      "AQA0oB7W-abxqIz6LLyzYT8HpszyiicMo85HOshLVkBZIP-55Dxo1A50HYSDskuEb4TMN9fOqskruhN_g_-fGpnAQyvBGAFRSfCVuPsbMzDgW45n9ZpJLcfX_IhYfZG2BIgSpKmQVoFuqM2pqUJE-feBVi_7MTlc2k9Saoii7sTyn44u8Ql7GS_MBAEiQ61NnClyw1rCRtJZSUoFpyIZrFSCmifQpMwBdkQVg3fDKUIXmEy45doc78Wf9_OG3PD7PRj21LR0O38barYHqGT9O0lJlNOPSMda6RSfNXaaycAGOchHVvPowcstDaNWnP8jvS_eLQBEwD-xt0hazjfziuznLVfrxlUgMLfE4F3pW4Scyg",
    "id" => "10212443153982146"
  }

  describe "create user (Google)" do
    test "renders JWT when data is valid", %{conn: conn} do
      params = Map.take(@google_auth_params, ["provider", "code"])

      conn =
        use_cassette "google_valid_oauth" do
          get(conn, auth_path(conn, :callback, "google"), params)
        end

      assert %{"meta" => %{"jwt" => token}} = json_response(conn, 201)

      {:ok, claims} = Guardian.decode_and_verify(token)
      {:ok, user} = Guardian.resource_from_claims(claims)

      assert user.email == "thiago.belem.web@gmail.com"
      assert user.first_name == "Thiago"
      assert user.last_name == "Belem"
      assert user.google_uid == @google_auth_params["id"]
      assert user.profile_image_url =~ ~r{https:\/\/lh3.googleusercontent.com\/.*\/photo.jpg\?sz=50}
    end
  end

  describe "login user (Google)" do
    test "renders JWT when data is valid", %{conn: conn} do
      user = insert(:user, email: "thiago.belem.web@gmail.com", google_uid: @google_auth_params["id"])
      id = user.id

      params = Map.take(@google_auth_params, ["provider", "code"])

      conn =
        use_cassette "google_valid_oauth" do
          get(conn, auth_path(conn, :callback, "google"), params)
        end

      assert %{"meta" => %{"jwt" => token}, "data" => %{"id" => ^id}} = json_response(conn, 200)
    end
  end

  describe "create user (Facebook)" do
    test "renders JWT when data is valid", %{conn: conn} do
      params = Map.take(@facebook_auth_params, ["provider", "code"])

      conn =
        use_cassette "facebook_valid_oauth" do
          get(conn, auth_path(conn, :callback, "facebook"), params)
        end

      assert %{"meta" => %{"jwt" => token}} = json_response(conn, 201)

      {:ok, claims} = Guardian.decode_and_verify(token)
      {:ok, user} = Guardian.resource_from_claims(claims)

      assert user.email == "contato@thiagobelem.net"
      assert user.first_name == "Thiago"
      assert user.last_name == "Belem"
      assert user.facebook_uid == @facebook_auth_params["id"]
      assert user.profile_image_url == "https://graph.facebook.com/v3.2/#{user.facebook_uid}/picture?type=normal"
    end
  end

  describe "login user (Facebook)" do
    test "renders JWT when data is valid", %{conn: conn} do
      user = insert(:user, email: "contato@thiagobelem.net", facebook_uid: @facebook_auth_params["id"])
      id = user.id

      params = Map.take(@facebook_auth_params, ["provider", "code"])

      conn =
        use_cassette "facebook_valid_oauth" do
          get(conn, auth_path(conn, :callback, "facebook"), params)
        end

      assert %{"meta" => %{"jwt" => token}, "data" => %{"id" => ^id}} = json_response(conn, 200)
    end
  end
end
