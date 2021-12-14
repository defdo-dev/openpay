defmodule Openpay.Authz.Endpoint do
  @moduledoc false
  use Phoenix.Endpoint, otp_app: :openpay

  plug(Plug.Telemetry, event_prefix: [:openpay, :endpoint])

  plug(Plug.Parsers, parsers: [:json], json_decoder: Phoenix.json_library())

  plug(Openpay.Authz.Router)
end
