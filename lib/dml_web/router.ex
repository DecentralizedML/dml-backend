defmodule DmlWeb.Router do
  use DmlWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", DmlWeb do
    pipe_through :api

    resources "/users", UserController, only: [:index, :create, :show]
    post "/users/authenticate", UserController, :authenticate
  end
end
