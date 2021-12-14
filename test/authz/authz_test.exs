defmodule Openpay.Authz.WebhookTest do
  @moduledoc """
  Handle the authz behaviour.

  Responses
     0 => Success
    12 => Invalid transaction
    30 => Invalid reference format
    88 => Invalid amount
    93 => Invalid reference
    96 => Service error
  """
  use Openpay.Authz.ConnCase, async: true

  describe "Authz Verify behaviour" do
    setup %{conn: conn} do
      Mox.stub_with(
        Openpay.Authz.VerifyMock,
        Openpay.Authz.Stub.Verify
      )

      {:ok, conn: log_in_basic(conn)}
    end

    @tag :authz_controller
    test "0 code purchase", %{conn: conn} do
      params = %{
        "folio" => "TEST891234567824",
        "local_date" => "2015-08-07T10:00:00-05:00",
        "amount" => 100.00,
        "trx_no" => 1_234_567_890
      }

      conn = post(conn, "/authz", params)

      assert %{"authorization_number" => 123_456, "response_code" => 0} = json_response(conn, 200)
    end

    @tag :authz_controller
    test "12 invalid transaction", %{conn: conn} do
      params = %{
        "folio" => "1234569988776655",
        "local_date" => "2015-08-07T10:00:00-05:00",
        "amount" => 100.00,
        "trx_no" => 1_234_567_890
      }

      conn = post(conn, "/authz", params)

      assert %{"error_description" => "Invalid transaction", "response_code" => 12} ==
               json_response(conn, 200)
    end

    @tag :authz_controller
    test "30 invalid reference format", %{conn: conn} do
      params = %{
        "folio" => "123456998877665",
        "local_date" => "2015-08-07T10:00:00-05:00",
        "amount" => 100.00,
        "trx_no" => 1_234_567_890
      }

      conn = post(conn, "/authz", params)

      assert %{"error_description" => "Invalid reference format", "response_code" => 30} ==
               json_response(conn, 200)
    end

    @tag :authz_controller
    test "88 invalid amount", %{conn: conn} do
      params = %{
        "folio" => "1234569988776659",
        "local_date" => "2015-08-07T10:00:00-05:00",
        "amount" => 0,
        "trx_no" => 1_234_567_890
      }

      conn = post(conn, "/authz", params)

      assert %{"error_description" => "Invalid amount", "response_code" => 88} ==
               json_response(conn, 200)
    end

    @tag :authz_controller
    test "93 invalid reference", %{conn: conn} do
      params = %{
        "folio" => "INVALID_REFERENCE",
        "local_date" => "2015-08-07T10:00:00-05:00",
        "amount" => 0,
        "trx_no" => 1_234_567_890
      }

      conn = post(conn, "/authz", params)

      assert %{"error_description" => "Invalid reference", "response_code" => 93} ==
               json_response(conn, 200)
    end

    @tag :authz_controller
    test "96 service error", %{conn: conn} do
      params = %{
        "folio" => "SERVICE_ERROR",
        "local_date" => "2015-08-07T10:00:00-05:00",
        "amount" => 0,
        "trx_no" => 1_234_567_890
      }

      conn = post(conn, "/authz", params)

      assert %{"error_description" => "Service error", "response_code" => 96} ==
               json_response(conn, 200)
    end

    @tag :authz_controller
    test "96 wrong parameters - custom description", %{conn: conn} do
      params = %{
        "folio" => "SERVICE_ERROR",
        "local_date" => "2015-08-07T10:00:00-05:00",
        "amount" => 0
      }

      conn = post(conn, "/authz", params)

      assert %{"error_description" => "The parameters are wrong", "response_code" => 96} ==
               json_response(conn, 200)
    end
  end

  describe "Authz Refund behaviour" do
    setup %{conn: conn} do
      Mox.stub_with(
        Openpay.Authz.RefundMock,
        Openpay.Authz.Stub.Refund
      )

      {:ok, conn: log_in_basic(conn)}
    end

    @tag :authz_controller
    test "12 invalid transaction", %{conn: conn} do
      params = %{
        "amount" => 100.00,
        "folio" => "INVALID_REFUND",
        "local_date" => "2021-12-13T15:26:08-06:00",
        "trx_no" => 1_234_567_890,
        "authorization_number" => 123_456
      }

      conn = delete(conn, "/authz", params)

      assert %{"error" => "Invalid reference number"} = json_response(conn, 412)
    end

    @tag :authz_controller
    test "409 invalid format date", %{conn: conn} do
      params = %{
        "amount" => 100.00,
        "folio" => "TEST891234567824",
        "local_date" => "2021-12-13",
        "trx_no" => 1_234_567_890,
        "authorization_number" => 123_456
      }

      conn = delete(conn, "/authz", params)

      assert %{"error" => "Invalid date format it must be ISO 8601"} = json_response(conn, 409)
    end

    @tag :authz_controller
    test "406 exceeded time 15 minutes", %{conn: conn} do
      params = %{
        "amount" => 100.00,
        "folio" => "TEST891234567824",
        "local_date" => "2021-12-13T15:26:08-06:00",
        "trx_no" => 1_234_567_890,
        "authorization_number" => 123_456
      }

      conn = delete(conn, "/authz", params)

      assert %{"error" => "Exceed 15 minutes"} = json_response(conn, 406)
    end

    @tag :authz_controller
    test "refund success", %{conn: conn} do
      dt = DateTime.now!("America/Mexico_City") |> DateTime.truncate(:second)
      now = DateTime.to_iso8601(dt)

      params = %{
        "amount" => 100.00,
        "folio" => "TEST891234567824",
        "local_date" => now,
        "trx_no" => 1_234_567_890,
        "authorization_number" => 123_456
      }

      conn = delete(conn, "/authz", params)

      assert %{} = json_response(conn, 200)
    end
  end
end
