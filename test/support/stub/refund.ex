defmodule Openpay.Authz.Stub.Refund do
  @moduledoc """
  Refund example
  """
  @behaviour Plug
  import Plug.Conn

  @tz "America/Mexico_City"
  @refund_gap -15 * 60

  def init(opts), do: opts

  def call(
        conn,
        %{
          "amount" => _amount,
          "folio" => _folio,
          "local_date" => _str_date,
          "trx_no" => _number,
          "authorization_number" => _auth_no
        } = params
      ) do
    validate(conn, params)
  end

  # 96 => "The parameters are wrong"
  def call(conn, _), do: json(conn, 409, error_response("The parameters are wrong"))

  def validate(conn, %{"folio" => "INVALID_REFUND"}) do
    json(conn, 412, error_response("Invalid reference number"))
  end

  def validate(conn, %{"local_date" => local_date} = params) when is_bitstring(local_date) do
    case DateTime.from_iso8601(local_date) do
      {:ok, local_date, _} ->
        local_date = DateTime.shift_zone!(local_date, @tz)
        validate(conn, %{params | "local_date" => local_date})

      _ ->
        json(conn, 409, error_response("Invalid date format it must be ISO 8601"))
    end
  end

  def validate(conn, %{"local_date" => local_date}) do
    now = @tz |> DateTime.now!() |> DateTime.add(@refund_gap, :second)

    case DateTime.compare(now, local_date) do
      :gt ->
        json(conn, 406, error_response("Exceed 15 minutes"))

      _ ->
        # this means local_date is within 15 minutes
        json(conn, 200)
    end
  end

  defp error_response(description) do
    %{error: description}
  end

  # if you are using phoenix consider to use Phoenix.Controller.json/2
  defp json(conn, code, params \\ %{}) do
    body = json_library().encode!(params)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, body)
  end

  defp json_library, do: Application.get_env(:phoenix, :json_library, Jason)
end
