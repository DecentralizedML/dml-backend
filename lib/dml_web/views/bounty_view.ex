defmodule DmlWeb.BountyView do
  use DmlWeb, :view
  alias DmlWeb.{BountyView, UserView}

  def render("index.json", %{bounties: bounties}) do
    render_many(bounties, BountyView, "bounty.json")
  end

  def render("show.json", %{bounty: bounty}) do
    render_one(bounty, BountyView, "bounty.json")
  end

  def render("bounty.json", %{bounty: bounty}) do
    %{
      id: bounty.id,
      name: bounty.name,
      description: bounty.description,
      start_date: bounty.start_date,
      end_date: bounty.end_date,
      evaluation_date: bounty.evaluation_date,
      state: bounty.state,
      owner: UserView.render("user.json", %{user: bounty.owner})
    }
  end
end
