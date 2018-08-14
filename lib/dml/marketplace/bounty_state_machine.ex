defmodule Dml.Marketplace.BountyStateMachine do
  alias Dml.Marketplace.Bounty
  alias Dml.Repo

  use Machinery,
    states: ["pending", "open", "closed", "finished"],
    transitions: %{
      "pending" => "open",
      "open" => "closed",
      "*" => "finished"
    }

  def persist(struct, next_state) do
    {:ok, bounty} =
      struct
      |> Bounty.update_state_changeset(%{state: next_state})
      |> Repo.update()

    bounty
  end
end
