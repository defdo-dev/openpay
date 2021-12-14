defmodule Openpay.Authz.ControllerAuthz do
  @moduledoc """
  Provides the bases to handle a request from Openpay.

  The intention for this webhook is to handle the rules to authorize or deny a request from an store.

  Since the request is made via HTTP protocol, It relays on Plug to handle the interactions.

  ### Configuration for verify

  ```elixir
  config :openpay, Openpay.Authz.Verify,
    module: MyApp.Plug.Authz.Verify
  ```

  ### Configuration for refund

  ```elixir
  config :openpay, Openpay.Authz.Refund,
    module: MyApp.Plug.Authz.Refund
  ```

  """
  require Logger
  use Phoenix.Controller
  plug(:auth when action in [:verify, :refund])

  @doc """
  Applies the provided module via config to verify it can be possible to handle the authorization.

  The module must implement the `:call` function and since the Plug behavior has it, It's recommended to use it.
  """
  def verify(conn, opts) do
    with [module: m] <- Application.get_env(:openpay, Openpay.Authz.Verify),
         conn = %Plug.Conn{} <- apply(m, :call, [conn, opts]) do
      conn
    else
      nil ->
        Logger.warn("Be sure that you must have the following configuration")

        Logger.warn("""
        In your config.exs file add.

        config :openpay, Openpay.Authz.Verify,
          module: MyApp.Plug.Authz.Verify
        """)

        error = %{
          error: "missing verify module configuration",
          docs:
            "https://paridincom.hexdocs.pm/openpay/Openpay.Authz.ControllerAuthz.html#module-configuration-for-verify"
        }

        conn
        |> put_status(501)
        |> json(error)
    end
  end

  @doc """
  Applies the provided module via config to refund the transaction.

  The module must implement the `:call` function and since the Plug behavior has it, It's recommended to use it.
  """
  def refund(conn, opts) do
    with [module: m] <- Application.get_env(:openpay, Openpay.Authz.Refund),
         conn = %Plug.Conn{} <- apply(m, :call, [conn, opts]) do
      conn
    else
      nil ->
        Logger.warn("Be sure that you must have the following configuration")

        Logger.warn("""
        In your config.exs file add.

        config :openpay, Openpay.Authz.Refund,
          module: MyApp.Plug.Authz.Refund
        """)

        error = %{
          error: "missing refund module configuration",
          docs:
            "https://paridincom.hexdocs.pm/openpay/Openpay.Authz.ControllerAuthz.html#module-configuration-for-refund"
        }

        conn
        |> put_status(501)
        |> json(error)
    end
  end

  defp auth(conn, _opts) do
    credentials = Application.fetch_env!(:openpay, Openpay.Authz.BasicAuth)
    Plug.BasicAuth.basic_auth(conn, credentials)
  end
end
