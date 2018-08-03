defmodule Dml.RenderJsonHelper do
  def render_json(view, template, assigns) do
    template |> view.render(assigns) |> format_json
  end

  defp format_json(data) do
    data |> Poison.encode!() |> Poison.decode!()
  end
end
