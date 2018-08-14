defmodule Dml.Marketplace.BountyStateMachine do
  alias Dml.Marketplace

  use Machinery,
    states: ["pending", "open", "closed", "finished"],
    transitions: %{
      "pending" => "open",
      "open" => "closed",
      "*" => "finished"
    }

  def persist(struct, next_state) do
    {:ok, bounty} = Marketplace.update_bounty(struct, %{state: next_state})
    bounty
  end
end
