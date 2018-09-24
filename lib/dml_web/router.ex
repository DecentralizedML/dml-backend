defmodule DmlWeb.Router do
  use DmlWeb, :router
  alias Dml.Guardian

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :jwt_authenticated do
    plug(Guardian.AuthPipeline)
  end

  scope "/auth", DmlWeb do
    if :prod != Mix.env(), do: get("/:provider", AuthController, :index)
    get("/:provider/callback", AuthController, :callback)
  end

  scope "/api", DmlWeb do
    pipe_through(:api)

    resources("/users", UserController, only: [:index, :create, :show])
    post("/users/authenticate", UserController, :authenticate)
  end

  scope "/api", DmlWeb do
    pipe_through([:api, :jwt_authenticated])

    get("/bounties/mine", BountyController, :mine)
    get("/algorithms/mine", AlgorithmController, :mine)

    resources("/bounties", BountyController, only: [:index, :create, :show, :update]) do
      put("/open", BountyController, :open, as: "open")
      put("/close", BountyController, :close, as: "close")
      put("/finish", BountyController, :finish, as: "finish")
      post("/enroll", BountyController, :enroll, as: "enroll")
    end

    resources("/algorithms", AlgorithmController, only: [:index, :create, :show, :update])

    put("/users", UserController, :update)
  end
end
