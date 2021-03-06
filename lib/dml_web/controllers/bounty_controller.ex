defmodule DmlWeb.BountyController do
  use DmlWeb, :controller

  alias Dml.Marketplace
  alias Dml.Marketplace.{Bounty}

  action_fallback(DmlWeb.FallbackController)

  def index(conn, _params) do
    bounties = Marketplace.list_open_bounties()
    render(conn, "index.json", data: bounties)
  end

  def mine(conn, _params) do
    bounties = Marketplace.list_bounties_from_user(current_user(conn))
    render(conn, "index.json", data: bounties)
  end

  def create(conn, %{"bounty" => bounty_params}) do
    with {:ok, %Bounty{} = bounty} <- Marketplace.create_bounty(current_user(conn).id, bounty_params),
         bounty <- Marketplace.get_bounty!(bounty.id) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.bounty_path(conn, :show, bounty))
      |> render("show.json", data: bounty)
    end
  end

  def show(conn, %{"id" => id}) do
    bounty = Marketplace.get_bounty!(id)
    render(conn, "show.json", data: bounty)
  end

  def update(conn, %{"id" => id, "bounty" => bounty_params}) do
    with bounty <- Marketplace.get_bounty!(id),
         :ok <- Bodyguard.permit(Marketplace, :update, current_user(conn), bounty),
         {:ok, %Bounty{} = bounty} <- Marketplace.update_bounty(bounty, bounty_params) do
      render(conn, "show.json", data: bounty)
    end
  end

  def reward(conn, %{"bounty_id" => id, "winners" => winners}) do
    with bounty <- Marketplace.get_bounty!(id),
         :ok <- Bodyguard.permit(Marketplace, :reward, current_user(conn), bounty),
         {:ok, %{reward: %Bounty{} = bounty}} <- Marketplace.reward_bounty(bounty, winners) do
      render(conn, "show.json", data: bounty)
    end
  end

  def open(conn, %{"bounty_id" => id}), do: update_state(conn, %{"bounty_id" => id, "state" => "open"})
  def close(conn, %{"bounty_id" => id}), do: update_state(conn, %{"bounty_id" => id, "state" => "closed"})
  def finish(conn, %{"bounty_id" => id}), do: update_state(conn, %{"bounty_id" => id, "state" => "finished"})

  defp update_state(conn, %{"bounty_id" => id, "state" => state}) do
    with bounty <- Marketplace.get_bounty!(id),
         :ok <- Bodyguard.permit(Marketplace, :update, current_user(conn), bounty),
         {:ok, %Bounty{} = bounty} <- Marketplace.update_bounty_state(bounty, state) do
      render(conn, "show.json", data: bounty)
    end
  end
end
