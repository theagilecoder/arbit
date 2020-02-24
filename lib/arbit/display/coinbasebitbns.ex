defmodule Arbit.Display.Coinbasebitbns do
  use Ecto.Schema
  alias Arbit.Track
  alias __MODULE__

  schema "coinbasebitbns" do
    field :coin,           :string
    field :quote_currency, :string
    field :coinbase_price, :float
    field :bitbns_price,   :float
    field :difference,     :float
    field :bitbns_volume,  :float

    timestamps()
  end


end
