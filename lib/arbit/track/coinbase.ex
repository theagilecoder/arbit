defmodule Arbit.Track.Coinbase do
  use Ecto.Schema
  # import Ecto.Changeset

  schema "coinbase" do
    field :product, :string
    field :price_usd, :float
    field :price_inr, :float

    timestamps()
  end

  @doc """
    Returns API URL
  """
  def url do
    base_url = "https://api.pro.coinbase.com/products/"
    product = "BTC-USD"

    "#{base_url}#{product}/ticker"
  end

  @doc """
    Calls API and returns coin price in Float even if price is Integer
  """
  def fetch_price do
    %{body: body} = HTTPoison.get! url()
    %{price: price} = Jason.decode!(body, [keys: :atoms])
    Float.parse(price) |> elem(0)
  end
end



