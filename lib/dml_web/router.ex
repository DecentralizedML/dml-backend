defmodule DmlWeb.Router do
  use DmlWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", DmlWeb do
    pipe_through :api
  end
end
