defmodule DmlWeb.AlgorithmViewTest do
  use DmlWeb.ConnCase, async: true
  alias DmlWeb.{AlgorithmView, UserView}

  test "algorithm.json" do
    algorithm = insert(:algorithm)
    rendered_algorithm = algorithm_json(algorithm)

    assert rendered_algorithm == %{
             id: algorithm.id,
             title: algorithm.title,
             description: algorithm.description,
             device_fee: algorithm.device_fee,
             state: algorithm.state,
             user: UserView.render("user.json", %{user: algorithm.user})
           }
  end

  test "index.json" do
    algorithm = insert(:algorithm)
    rendered_algorithms = AlgorithmView.render("index.json", %{algorithms: [algorithm]})

    assert rendered_algorithms == [algorithm_json(algorithm)]
  end

  test "show.json" do
    algorithm = insert(:algorithm)
    rendered_algorithm = AlgorithmView.render("show.json", %{algorithm: algorithm})

    assert rendered_algorithm == algorithm_json(algorithm)
  end

  defp algorithm_json(algorithm) do
    AlgorithmView.render("algorithm.json", %{algorithm: algorithm})
  end
end
