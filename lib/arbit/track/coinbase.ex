defmodule Arbit.Track.Coinbase do
  @moduledoc """
  This module calls Coinbase & Pro Coinbase APIs and prepares list of %Coinbase{} structs
  Coinbase has 14 coins. Pro Coinbase has 2 additional coins - ATOM-USD and ALGO-USD
  Pro Coinbase has a rate limit of 3 requests per second
  """

  use Ecto.Schema
  alias Arbit.Track
  alias __MODULE__

  schema "coinbase" do
    field :coin,           :string
    field :quote_currency, :string
    field :price_usd,      :float
    field :price_inr,      :float

    timestamps()
  end

  @doc """
    Gets the entire Coinbase portfolio with each product with its price_usd
    Each async task returns a tuple where the first element is either :ok or :error
    Also gets Pro Coinbase portfolio
    Adds the 2 portfolios
    Fills in the blanks in the structs
  """
  def fetch_portfolio do
    coinbase_portfolio =
      coinbase_coins_list()
      |> Task.async_stream(&fetch_price_coinbase/1)
      |> Enum.map(fn {:ok, result} -> result end)

    pro_coinbase_portfolio =
      pro_coinbase_coins_list()
      |> Task.async_stream(&fetch_price_pro_coinbase/1)
      |> Enum.map(fn {:ok, result} -> result end)

    portfolio = coinbase_portfolio ++ pro_coinbase_portfolio

    conversion_amount = Track.get_conversion_amount("USD-INR")

    portfolio
    |> Enum.map(&detect_quote_currency(&1))
    |> Enum.map(&sanitize_name(&1))
    |> Enum.map(&fill_blank_price_inr(&1, conversion_amount))
  end

  # Returns Coinbase's list of products
  defp coinbase_coins_list do
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

  # Returns Pro Coinbase's list of products
  defp pro_coinbase_coins_list do
    ~w(ATOM-USD ALGO-USD)
  end

  # Calls Coinbase API and returns struct of given product and price_usd in Float
  defp fetch_price_coinbase(coin) do
    %{body: body} = HTTPoison.get! coinbase_url(coin)

    price_usd =
      case Jason.decode!(body, [keys: :atoms]) do
        %{data: %{amount: amount}} -> Float.parse(amount) |> elem(0) |> Float.round(2)
        _                          -> "0"
      end

    %Coinbase{}
    |> struct(%{coin: coin})
    |> struct(%{price_usd: price_usd})
  end

  # Calls Pro Coinbase API and returns struct of given product and price_usd in Float
  defp fetch_price_pro_coinbase(coin) do
    %{body: body} = HTTPoison.get! pro_coinbase_url(coin)

    price_usd =
      case Jason.decode!(body, [keys: :atoms]) do
        %{price: price} -> Float.parse(price) |> elem(0) |> Float.round(2)
        _               -> "0"
      end

    %Coinbase{}
    |> struct(%{coin: coin})
    |> struct(%{price_usd: price_usd})
  end

  # Returns Coinbase API URL of a given product
  defp coinbase_url(coin) do
    "https://api.coinbase.com/v2/prices/#{coin}/spot"
  end

  # Returns Pro Coinbase API URL of a given product
  defp pro_coinbase_url(coin) do
    "https://api.pro.coinbase.com/products/#{coin}/ticker"
  end

  # Fills quote_currency key in the struct
  defp detect_quote_currency(coin) do
    struct(coin, %{quote_currency: "USD"})
  end

  # Changes name from "BTC-USD" to "BTC"
  defp sanitize_name(coin) do
    sanitized_name = String.replace_trailing(coin.coin, "-USD", "")
    struct(coin,%{coin: sanitized_name})
  end

  # Fills price inr
  defp fill_blank_price_inr(%Coinbase{price_usd: price_usd} = coin, conversion_amount) do
    struct(coin, %{price_inr: price_usd * conversion_amount |> Float.round(6)})
  end
end
