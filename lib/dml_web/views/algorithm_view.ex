defmodule DmlWeb.AlgorithmView do
  use DmlWeb, :view
  alias DmlWeb.{AlgorithmView, UserView}
  alias Dml.Marketplace.Algorithm

  def render("index.json", %{algorithms: algorithms}) do
    render_many(algorithms, AlgorithmView, "algorithm.json")
  end

  def render("show.json", %{algorithm: algorithm}) do
    render_one(algorithm, AlgorithmView, "algorithm.json")
  end

  def render("algorithm.json", %{algorithm: algorithm}) do
    %{
      id: algorithm.id,
      title: algorithm.title,
      description: algorithm.description,
      device_fee: algorithm.device_fee,
      # file: DmlWeb.Algorithm.url({algorithm.file, algorithm}, :original, signed: true),
      downloads: downloads(algorithm),
      state: algorithm.state,
      user: UserView.render("user.json", %{user: algorithm.user})
    }
  end

  def downloads(%Algorithm{downloads: count}) when count >= 1_000_000, do: "#{Float.round(count / 1_000_000, 1)}m"
  def downloads(%Algorithm{downloads: count}) when count >= 1_000, do: "#{Float.round(count / 1_000, 1)}k"
  def downloads(%Algorithm{downloads: count}), do: "#{count}"
end
