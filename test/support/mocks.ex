defmodule Support.Mocks do
  @moduledoc false
  Application.ensure_all_started(:mox)
  Mox.defmock(Openpay.Authz.VerifyMock, for: Plug)
  Mox.defmock(Openpay.Authz.RefundMock, for: Plug)
end
