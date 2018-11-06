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
             downloads: AlgorithmView.downloads(algorithm),
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

  describe "downloads/1" do
    test "with less than 1k downloads" do
      algorithm = build(:algorithm, downloads: 751)
      assert AlgorithmView.downloads(algorithm) == "751"
    end

    test "with more than 1k downloads" do
      algorithm = build(:algorithm, downloads: 3421)
      assert AlgorithmView.downloads(algorithm) == "3.4k"
    end

    test "with more than 1m downloads" do
      algorithm = build(:algorithm, downloads: 3_321_421)
      assert AlgorithmView.downloads(algorithm) == "3.3m"
    end
  end

  defp algorithm_json(algorithm) do
    AlgorithmView.render("algorithm.json", %{algorithm: algorithm})
  end
end
