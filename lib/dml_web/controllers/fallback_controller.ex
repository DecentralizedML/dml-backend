defmodule DmlWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use DmlWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(DmlWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(DmlWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(DmlWeb.ErrorView)
    |> render(:"401")
  end

  def call(conn, {:error, _message}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(DmlWeb.ErrorView)
    |> render(:"403")
  end

  def auth_error(conn, {_type, _reason}, _opts), do: call(conn, {:error, :unauthorized})
end
