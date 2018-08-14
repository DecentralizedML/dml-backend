defmodule DmlWeb.Router do
  use DmlWeb, :router
  alias Dml.Guardian

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :jwt_authenticated do
    plug(Guardian.AuthPipeline)
  end

  scope "/api", DmlWeb do
    pipe_through(:api)

    resources("/users", UserController, only: [:index, :create, :show])
    post("/users/authenticate", UserController, :authenticate)
  end

  scope "/api", DmlWeb do
    pipe_through([:api, :jwt_authenticated])

    get("/bounties/mine", BountyController, :mine)

    resources("/bounties", BountyController, only: [:index, :create, :show, :update]) do
      put("/open", BountyController, :open)
      put("/close", BountyController, :close)
      put("/finish", BountyController, :finish)
    end

    put("/users", UserController, :update)
  end
end
