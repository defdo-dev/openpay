defmodule Openpay.Authz.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.
  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.
  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use Defdo.WalletWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  import Plug.BasicAuth
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import Openpay.Authz.ConnCase

      alias Openpay.Authz.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint Openpay.Authz.Endpoint
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def log_in_basic(conn) do
    [username: username, password: password] =
      Application.fetch_env!(:openpay, Openpay.Authz.BasicAuth)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_req_header("authorization", encode_basic_auth(username, password))
    |> basic_auth(username: username, password: password)
  end
end
