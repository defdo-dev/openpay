import Config

config :money,
  default_currency: :MXN

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :openpay, Openpay.Authz.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  https: [
    port: String.to_integer(System.get_env("HTTPS_PORT", "4001")),
    otp_app: :defdo_wallet,
    certfile: System.get_env("HTTPS_CERT_FILE") || "priv/ssl/openpay.pem",
    keyfile: System.get_env("HTTPS_KEY_FILE") || "priv/ssl/openpay_key.pem"
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base:
    System.get_env(
      "OPENPAY_SECRET_BASE",
      "7VX8Fbnzb5c2Izmex+tdmYIFoHyle6NxcEHlufHMQ6AZ/WOFP802Q37B4u72vqIa"
    )

config :openpay,
  api_env: System.get_env("OPENPAY_API_ENV", "sandbox"),
  merchant_id: System.fetch_env!("OPENPAY_ID"),
  client_secret: System.fetch_env!("OPENPAY_SK"),
  client_public: System.fetch_env!("OPENPAY_PK")

config :openpay, Openpay.Authz.BasicAuth,
  username: System.get_env("OPENPAY_BASIC_AUTH_USERNAME"),
  password: System.get_env("OPENPAY_BASIC_AUTH_PASSWORD")

if Mix.env() == :test do
  config :logger, level: :error

  config :openpay, Openpay.Authz.Verify, module: Openpay.Authz.VerifyMock
  config :openpay, Openpay.Authz.Refund, module: Openpay.Authz.RefundMock

  # After refactor webhook & antifraud remove the following values.
  config :openpay,
    api_env: "sandbox",
    merchant_id: "mjtkrswiqtxftemz4tgl",
    client_secret: "sk_da05dc98605d4e1d880582b4ee621e84",
    client_public: "pk_8ffec93a697248e881cd4f67d027f81a"
end
