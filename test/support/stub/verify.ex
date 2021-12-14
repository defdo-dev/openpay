defmodule Openpay.Authz.Stub.Verify do
  @moduledoc """
  Example to implement a verification plug
  """
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(
        conn,
        %{
          "amount" => _amount,
          "folio" => _folio,
          "local_date" => _local_date,
          "trx_no" => _transaction
        } = params
      ) do
    json(conn, validate(params))
  end

  # 96 => "The parameters are wrong"
  def call(conn, _), do: json(conn, error_response(96, "The parameters are wrong"))

  # handle error validates
  # 96 => "Service error"
  def validate(%{"folio" => "SERVICE_ERROR"}) do
    error_response(96)
  end

  # 93 => "Invalid reference"
  def validate(%{"folio" => "INVALID_REFERENCE"}) do
    error_response(93)
  end

  # 88 => "Invalid amount"
  def validate(%{"amount" => 0}) do
    error_response(88)
  end

  # 30 => "Invalid reference format"
  def validate(%{"folio" => reference}) when byte_size(reference) != 16 do
    error_response(30)
  end

  # 12 => "Invalid transaction"
  def validate(%{"folio" => "1234569988776655"}) do
    error_response(12)
  end

  # handle success case
  # 0 => "Success"
  def validate(_params) do
    auth_number = 123_456
    success_response(auth_number)
  end

  # helpers
  defp codes do
    %{
      0 => "Success",
      12 => "Invalid transaction",
      30 => "Invalid reference format",
      88 => "Invalid amount",
      93 => "Invalid reference",
      96 => "Service error"
    }
  end

  # The store accepts the payment
  defp success_response(auth_number) do
    %{response_code: 0, authorization_number: auth_number}
  end

  # The store reject the payment
  defp error_response(code, custom_description \\ nil) do
    description =
      case custom_description do
        nil -> Map.get(codes(), code)
        description -> description
      end

    %{response_code: code, error_description: description}
  end

  # if you are using phoenix consider to use Phoenix.Controller.json/2
  defp json(conn, params) do
    body = json_library().encode!(params)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, body)
  end

  defp json_library, do: Application.get_env(:phoenix, :json_library, Jason)
end
