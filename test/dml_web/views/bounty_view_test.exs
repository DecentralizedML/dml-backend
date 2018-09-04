defmodule DmlWeb.BountyViewTest do
  use DmlWeb.ConnCase, async: true
  alias DmlWeb.{BountyView, UserView}

  test "bounty.json" do
    bounty = insert(:bounty)
    rendered_bounty = bounty_json(bounty)

    assert rendered_bounty == %{
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

  test "index.json" do
    bounty = insert(:bounty)
    rendered_bounties = BountyView.render("index.json", %{bounties: [bounty]})

    assert rendered_bounties == [bounty_json(bounty)]
  end

  test "show.json" do
    bounty = insert(:bounty)
    rendered_bounty = BountyView.render("show.json", %{bounty: bounty})

    assert rendered_bounty == bounty_json(bounty)
  end

  test "enrollment.json" do
    enrollment = insert(:enrollment)
    rendered_enrollment = enrollment_json(enrollment)

    assert rendered_enrollment == %{
             id: enrollment.id,
             user: UserView.render("user.json", %{user: enrollment.user}),
             bounty: BountyView.render("bounty.json", %{bounty: enrollment.bounty}),
             state: enrollment.state,
             rewarded: enrollment.rewarded,
             reward: enrollment.reward,
             rank: enrollment.rank
           }
  end

  defp bounty_json(bounty) do
    BountyView.render("bounty.json", %{bounty: bounty})
  end

  defp enrollment_json(enrollment) do
    BountyView.render("enrollment.json", %{enrollment: enrollment})
  end
end
