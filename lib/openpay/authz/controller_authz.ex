defmodule Openpay.Authz.ControllerAuthz do
  @moduledoc """
  Provides the bases to handle a request from Openpay.

  The intention for this webhook is to handle the rules to authorize or deny a request from an store.

  Since the request is made via HTTP protocol, It relays on Plug to handle the interactions.
  """
  require Logger
  use Phoenix.Controller
  plug(:auth when action in [:index, :verify, :refund])

  def index(conn, _opts) do
    json(conn, heartbeat())
  end

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
            module: Openpay.Authz.Example.Verify

        Remember to change the module with yours.
        Notice that the module must be a Plug.
        """)

        error = %{
          error: "missing verify module configuration",
          docs: "https://paridincom.hexdocs.pm/openpay/Openpay.html"
        }

        conn
        |> put_status(501)
        |> json(error)
    end
  end

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
            module: Openpay.Authz.Example.Refund

        Remember to change the module with yours.
        Notice that the module must be a Plug.
        """)

        error = %{
          error: "missing refund module configuration",
          docs: "https://paridincom.hexdocs.pm/openpay/Openpay.html"
        }

        conn
        |> put_status(501)
        |> json(error)
    end
  end

  defp heartbeat do
    %{
      data: %{
        status: "online",
        powered_by: "defdo.dev™"
      }
    }
  end

  defp auth(conn, _opts) do
    credentials = Application.fetch_env!(:openpay, Openpay.Authz.BasicAuth)
    Plug.BasicAuth.basic_auth(conn, credentials)
  end
end
