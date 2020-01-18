defmodule Arbit.Track.Coinbase do
  use Ecto.Schema
  # import Ecto.Changeset
  alias __MODULE__

  schema "coinbase" do
    field :product, :string
    field :price_usd, :float
    field :price_inr, :float

    timestamps()
  end

  @doc """
    Returns Coinbase's list of products
  """
  def product_list do
    ~w(
      BTC-USD
      ETH-USD
      LTC-USD
      BCH-USD
      EOS-USD
      DASH-USD
      ETC-USD
      XLM-USD
      XTZ-USD
      OXT-USD
      REP-USD
      XRP-USD
      LINK-USD
      ZRX-USD
    )
  end

  @doc """
    Returns API URL of a given product
  """
  def url(product) do
    "https://api.coinbase.com/v2/prices/#{product}/spot"
  end

  @doc """
    Calls API and returns struct of given product and price in Float even if price is Integer
  """
  def fetch_price(product) do
    %{body: body} = HTTPoison.get! url(product)

    amount = case Jason.decode!(body, [keys: :atoms]) do
                %{data: %{amount: amount}} -> amount
                _ -> 0
              end

    %Coinbase{}
    |> struct(%{product: product})
    |> struct(%{price_usd: Float.parse(amount) |> elem(0) |> Float.round(2)})
  end

  @doc """
    Gets the entire Coinbase portfolio with each product with its price_usd
    Every task returns a tuple where the first element is either :ok or :error
  """
  def fetch_portfolio do
    product_list()
    |> Task.async_stream(&fetch_price/1)
    |> Enum.map(fn {:ok, result} -> result end)
  end
end
