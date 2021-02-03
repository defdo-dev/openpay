defmodule Openpay.Types.Token do
    @moduledoc """
    Required schema to create a token it return id_token and it will be used
    as
    """

    use Ecto.Schema

    @primary_key false
    embedded_schema do
      field(:holder_name, :string)
      field(:card_number, :string)
      field(:expiration_month, :string)
      field(:expiration_year, :string)
      field(:cvv2, :string)
    end
end
