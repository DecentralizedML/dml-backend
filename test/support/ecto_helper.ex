defmodule Dml.EctoHelper do
  def has_element_by_id(list, %{id: element_id}) do
    Enum.find(list, nil, fn %{id: id} -> id == element_id end) != nil
  end
end
