defmodule DmlWeb.PageController do
  use DmlWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
