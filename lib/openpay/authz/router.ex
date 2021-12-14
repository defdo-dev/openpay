defmodule Openpay.Authz.Router do
  @moduledoc """
  Authz Router to handle the default behaviour
  """
  use Phoenix.Router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/authz", Openpay.Authz do
    pipe_through(:api)

    get("/", ControllerAuthz, :index)
    post("/", ControllerAuthz, :verify)
    delete("/", ControllerAuthz, :refund)
  end
end
