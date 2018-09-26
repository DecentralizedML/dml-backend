defmodule DmlWeb.AlgorithmView do
  use DmlWeb, :view
  alias DmlWeb.{AlgorithmView, UserView}

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
      state: algorithm.state,
      user: UserView.render("user.json", %{user: algorithm.user})
    }
  end
end
