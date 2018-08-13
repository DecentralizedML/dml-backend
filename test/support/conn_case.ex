defmodule DmlWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox
  alias Phoenix.ConnTest

  alias Dml.Factory
  alias Dml.Guardian.Plug

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import DmlWeb.Router.Helpers
      import Dml.RenderJsonHelper
      import Dml.Factory
      alias Dml.Guardian.Plug

      # The default endpoint for testing
      @endpoint DmlWeb.Endpoint
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Dml.Repo)

    unless tags[:async] do
      Sandbox.mode(Dml.Repo, {:shared, self()})
    end

    if tags[:authenticated] do
      # Creates & authenticates user
      user = Factory.insert(:user)
      conn = Plug.sign_in(ConnTest.build_conn(), user)
      {:ok, conn: conn, user: user}
    else
      {:ok, conn: ConnTest.build_conn()}
    end
  end
end
