defmodule DmlWeb.AlgorithmController do
  use DmlWeb, :controller

  alias Dml.Marketplace
  alias Dml.Marketplace.Algorithm

  action_fallback(DmlWeb.FallbackController)

  def index(conn, _params) do
    algorithms = Marketplace.list_algorithms()
    render(conn, "index.json", data: algorithms)
  end

  def mine(conn, _params) do
    algorithms = Marketplace.list_algorithms_from_user(current_user(conn))
    render(conn, "index.json", data: algorithms)
  end

  def create(conn, %{"algorithm" => algorithm_params}) do
    with {:ok, %Algorithm{} = algorithm} <- Marketplace.create_algorithm(current_user(conn).id, algorithm_params),
         algorithm <- Marketplace.get_algorithm!(algorithm.id) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.algorithm_path(conn, :show, algorithm))
      |> render("show.json", data: algorithm)
    end
  end

  def show(conn, %{"id" => id}) do
    algorithm = Marketplace.get_algorithm!(id)
    render(conn, "show.json", data: algorithm)
  end

  def update(conn, %{"id" => id, "algorithm" => algorithm_params}) do
    with algorithm <- Marketplace.get_algorithm!(id),
         :ok <- Bodyguard.permit(Marketplace, :update, current_user(conn), algorithm),
         {:ok, %Algorithm{} = algorithm} <- Marketplace.update_algorithm(algorithm, algorithm_params) do
      render(conn, "show.json", data: algorithm)
    end
  end

  def download(conn, %{"algorithm_id" => id}) do
    with algorithm <- Marketplace.get_algorithm!(id),
         :ok <- Bodyguard.permit(Marketplace, :download, current_user(conn), algorithm) do
      case DmlWeb.Algorithm.url({algorithm.file, algorithm}, :original, signed: true) do
        nil -> conn |> put_status(:not_found) |> put_view(DmlWeb.ErrorView) |> render("404.json")
        url -> conn |> redirect(external: url)
      end
    end
  end
end
