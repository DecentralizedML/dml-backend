defmodule DmlWeb.BountyController do
  use DmlWeb, :controller

  alias Dml.Guardian.Plug
  alias Dml.Marketplace
  alias Dml.Marketplace.Bounty

  action_fallback(DmlWeb.FallbackController)

  def index(conn, _params) do
    bounties = Marketplace.list_bounties()
    render(conn, "index.json", bounties: bounties)
  end

  def mine(conn, _params) do
    user = Plug.current_resource(conn)
    bounties = Marketplace.list_bounties_from_user(user)
    render(conn, "index.json", bounties: bounties)
  end

  def create(conn, %{"bounty" => bounty_params}) do
    with user <- Plug.current_resource(conn),
         {:ok, %Bounty{} = bounty} <- Marketplace.create_bounty(user.id, bounty_params),
         bounty <- Marketplace.get_bounty!(bounty.id) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", bounty_path(conn, :show, bounty))
      |> render("show.json", bounty: bounty)
    end
  end

  def show(conn, %{"id" => id}) do
    bounty = Marketplace.get_bounty!(id)
    render(conn, "show.json", bounty: bounty)
  end

  def update(conn, %{"id" => id, "bounty" => bounty_params}) do
    with user <- Plug.current_resource(conn),
         bounty <- Marketplace.get_bounty!(id),
         :ok <- Bodyguard.permit(Marketplace, :update_bounty, user, bounty),
         {:ok, %Bounty{} = bounty} <- Marketplace.update_bounty(bounty, bounty_params) do
      render(conn, "show.json", bounty: bounty)
    end
  end
end
