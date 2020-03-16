defmodule Arbit.Display.Coinbasecoindcx do
  @moduledoc """
    This module is responsible for
    defining the model schema and
    computing arbitrage between Coinbase & CoinDCX
  """

  use Ecto.Schema
  alias Arbit.Track
  alias __MODULE__

  schema "coinbasecoindcx" do
    field :coin,              :string
    field :quote_currency,    :string
    field :coinbase_price,    :float
    field :coindcx_bid_price, :float
    field :coindcx_ask_price, :float
    field :bid_difference,    :float
    field :ask_difference,    :float
    field :coindcx_volume,    :float

    timestamps()
  end

  @doc """
  Compute arbitrage between Coinbase & CoinDCX
  & return a list of %Coinbasecoindcx{} structs
  """
  def compute_arbitrage do
    compute_arbitrage_inr_market() ++ compute_arbitrage_usdt_market()
      ++ compute_arbitrage_tusd_market() ++ compute_arbitrage_usdc_market()
  end

  @doc """
  Compute arbitrage between Coinbase USD coins & CoinDCX INR coins
  and return a list of %Coinbasecoindcx{} structs
  """
  def compute_arbitrage_inr_market() do
    # Get Coinbase & CoinDCX portfolios
    coinbase_portfolio = Track.list_coinbase()
    coindcx_portfolio  = Track.list_coindcx()

    # Filter in the coins belonging to the relevant market
    coinbase_portfolio = filter_market(coinbase_portfolio, "USD")
    coindcx_portfolio  = filter_market(coindcx_portfolio,  "INR")

    # Filter in common coins in the two portfolios
    coinbase_portfolio = filter_common_coins(coinbase_portfolio, coindcx_portfolio)
    coindcx_portfolio  = filter_common_coins(coindcx_portfolio, coinbase_portfolio)

    # Sort each portfolio by coin name
    coinbase_portfolio = Enum.sort_by(coinbase_portfolio, &(&1.coin))
    coindcx_portfolio  = Enum.sort_by(coindcx_portfolio,  &(&1.coin))

    # Zip the two portfolios
    zipped_portfolios = Enum.zip(coinbase_portfolio, coindcx_portfolio)

    # Create %Coinbasecoindcx{} struct with difference %
    Enum.map(zipped_portfolios, & create_coinbasecoindcx_struct(&1))
  end

  @doc """
  Compute arbitrage between Coinbase USD coins & CoinDCX USDT coins
  and return a list of %Coinbasecoindcx{} structs
  """
  def compute_arbitrage_usdt_market() do
    # Get Coinbase & CoinDCX portfolios
    coinbase_portfolio = Track.list_coinbase()
    coindcx_portfolio  = Track.list_coindcx()

    # Filter in the coins belonging to the relevant market
    coinbase_portfolio = filter_market(coinbase_portfolio, "USD")
    coindcx_portfolio  = filter_market(coindcx_portfolio, "USDT")

    # Filter in common coins in the two portfolios
    coinbase_portfolio = filter_common_coins(coinbase_portfolio, coindcx_portfolio)
    coindcx_portfolio  = filter_common_coins(coindcx_portfolio, coinbase_portfolio)

    # Sort each portfolio by coin name
    coinbase_portfolio = Enum.sort_by(coinbase_portfolio, &(&1.coin))
    coindcx_portfolio  = Enum.sort_by(coindcx_portfolio,  &(&1.coin))

    # Zip the two portfolios
    zipped_portfolios = Enum.zip(coinbase_portfolio, coindcx_portfolio)

    # Create %Coinbasecoindcx{} struct with difference %
    Enum.map(zipped_portfolios, & create_coinbasecoindcx_struct(&1))
  end

  @doc """
  Compute arbitrage between Coinbase USD coins & CoinDCX TUSD coins
  and return a list of %Coinbasecoindcx{} structs
  """
  def compute_arbitrage_tusd_market() do
    # Get Coinbase & CoinDCX portfolios
    coinbase_portfolio = Track.list_coinbase()
    coindcx_portfolio  = Track.list_coindcx()

    # Filter in the coins belonging to the relevant market
    coinbase_portfolio = filter_market(coinbase_portfolio, "USD")
    coindcx_portfolio  = filter_market(coindcx_portfolio, "TUSD")

    # Filter in common coins in the two portfolios
    coinbase_portfolio = filter_common_coins(coinbase_portfolio, coindcx_portfolio)
    coindcx_portfolio  = filter_common_coins(coindcx_portfolio, coinbase_portfolio)

    # Sort each portfolio by coin name
    coinbase_portfolio = Enum.sort_by(coinbase_portfolio, &(&1.coin))
    coindcx_portfolio  = Enum.sort_by(coindcx_portfolio,  &(&1.coin))

    # Zip the two portfolios
    zipped_portfolios = Enum.zip(coinbase_portfolio, coindcx_portfolio)

    # Create %Coinbasecoindcx{} struct with difference %
    Enum.map(zipped_portfolios, & create_coinbasecoindcx_struct(&1))
  end

  @doc """
  Compute arbitrage between Coinbase USD coins & CoinDCX USDC coins
  and return a list of %Coinbasecoindcx{} structs
  """
  def compute_arbitrage_usdc_market() do
    # Get Coinbase & CoinDCX portfolios
    coinbase_portfolio = Track.list_coinbase()
    coindcx_portfolio  = Track.list_coindcx()

    # Filter in the coins belonging to the relevant market
    coinbase_portfolio = filter_market(coinbase_portfolio, "USD")
    coindcx_portfolio  = filter_market(coindcx_portfolio, "USDC")

    # Filter in common coins in the two portfolios
    coinbase_portfolio = filter_common_coins(coinbase_portfolio, coindcx_portfolio)
    coindcx_portfolio  = filter_common_coins(coindcx_portfolio, coinbase_portfolio)

    # Sort each portfolio by coin name
    coinbase_portfolio = Enum.sort_by(coinbase_portfolio, &(&1.coin))
    coindcx_portfolio  = Enum.sort_by(coindcx_portfolio,  &(&1.coin))

    # Zip the two portfolios
    zipped_portfolios = Enum.zip(coinbase_portfolio, coindcx_portfolio)

    # Create %Coinbasecoindcx{} struct with difference %
    Enum.map(zipped_portfolios, & create_coinbasecoindcx_struct(&1))
  end

  #-------------------#
  # Private Functions #
  #-------------------#

  defp filter_market(portfolio, currency) do
    Enum.filter(portfolio, fn %{quote_currency: quote_currency} -> quote_currency == currency end)
  end

  # Keep those coins in first portfolio that is also present in second portfolio
  defp filter_common_coins(first_portfolio, second_portfolio) do
    Enum.filter(first_portfolio, fn %{coin: coin} -> coin_present_in?(coin, second_portfolio) end)
  end

  defp coin_present_in?(coin, portfolio) do
    Enum.any?(portfolio, fn %{coin: coin_in_struct} -> coin == coin_in_struct end)
  end

  # Create %Coinbasecoindcx{} struct and fills them
  defp create_coinbasecoindcx_struct({coinbase_portfolio, coindcx_portfolio}) do
    %Coinbasecoindcx{}
    |> struct(%{coin:              coinbase_portfolio.coin})
    |> struct(%{quote_currency:    coindcx_portfolio.quote_currency})
    |> struct(%{coinbase_price:    coinbase_portfolio.price_usd})
    |> struct(%{coindcx_bid_price: coindcx_portfolio.bid_price_inr})
    |> struct(%{bid_difference:    compute_difference(coinbase_portfolio.price_inr, coindcx_portfolio.bid_price_inr)})
    |> struct(%{coindcx_ask_price: coindcx_portfolio.ask_price_inr})
    |> struct(%{ask_difference:    compute_difference(coinbase_portfolio.price_inr, coindcx_portfolio.ask_price_inr)})
    |> struct(%{coindcx_volume:    coindcx_portfolio.volume})
  end

  # Compute difference %
  defp compute_difference(price1, price2) do
    (price2 - price1) / price1 * 100 |> Float.round(2)
  end
end
