defmodule Openpay.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Openpay.Authz.Endpoint
    ] ++ maybe_start_openpay()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Openpay.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp maybe_start_openpay do
    if validate_all_app_keys(:openpay, ~w(api_env merchant_id client_secret client_public)a) do
      [Openpay.ConfigState]
    else
      []
    end
  end

  def validate_all_app_keys(app, keys) do
    Enum.all?(keys, fn key -> Application.get_env(app, key) end)
  end
end
