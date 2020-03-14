defmodule Arbit.Display.Coinbasewazirx do
  @moduledoc """
    This module is responsible for
    defining the model schema and
    computing arbitrage between Coinbase & WazirX
  """

  use Ecto.Schema
  alias Arbit.Track
  alias __MODULE__

  schema "coinbasewazirx" do
    field :coin,             :string
    field :quote_currency,   :string
    field :coinbase_price,   :float
    field :wazirx_bid_price, :float
    field :wazirx_ask_price, :float
    field :bid_difference,   :float
    field :ask_difference,   :float
    field :wazirx_volume,    :float

    timestamps()
  end

  @doc """
  Compute arbitrage between Coinbase & WazirX
  & return a list of %Coinbasewazirx{} structs
  """
  def compute_arbitrage do
    compute_arbitrage_inr_market() ++ compute_arbitrage_usdt_market()
  end

  @doc """
  Compute arbitrage between Coinbase USD coins & WazirX INR coins
  and return a list of %Coinbasewazirx{} structs
  """
  def compute_arbitrage_inr_market() do
    # Get Coinbase & Wazirx portfolios
    coinbase_portfolio = Track.list_coinbase()
    wazirx_portfolio   = Track.list_wazirx()

    # Filter in the coins belonging to the relevant market
    coinbase_portfolio = filter_market(coinbase_portfolio, "USD")
    wazirx_portfolio   = filter_market(wazirx_portfolio,   "INR")

    # Filter in common coins in the two portfolios
    coinbase_portfolio = filter_common_coins(coinbase_portfolio, wazirx_portfolio)
    wazirx_portfolio   = filter_common_coins(wazirx_portfolio, coinbase_portfolio)

    # Sort each portfolio by coin name
    coinbase_portfolio = Enum.sort_by(coinbase_portfolio, &(&1.coin))
    wazirx_portfolio   = Enum.sort_by(wazirx_portfolio,   &(&1.coin))

    # Zip the two portfolios
    zipped_portfolios = Enum.zip(coinbase_portfolio, wazirx_portfolio)

    # Create %Coinbasewazirx{} struct with difference %
    Enum.map(zipped_portfolios, & create_coinbasewazirx_struct(&1))
  end

  @doc """
  Compute arbitrage between Coinbase USD coins & WazirX USDT coins
  and return a list of %Coinbasewazirx{} structs
  """
  def compute_arbitrage_usdt_market() do
    # Get Coinbase & WazirX portfolios
    coinbase_portfolio = Track.list_coinbase()
    wazirx_portfolio   = Track.list_wazirx()

    # Filter in the coins belonging to the relevant market
    coinbase_portfolio = filter_market(coinbase_portfolio, "USD")
    wazirx_portfolio   = filter_market(wazirx_portfolio,  "USDT")

    # Filter in common coins in the two portfolios
    coinbase_portfolio = filter_common_coins(coinbase_portfolio, wazirx_portfolio)
    wazirx_portfolio   = filter_common_coins(wazirx_portfolio, coinbase_portfolio)

    # Sort each portfolio by coin name
    coinbase_portfolio = Enum.sort_by(coinbase_portfolio, &(&1.coin))
    wazirx_portfolio   = Enum.sort_by(wazirx_portfolio,   &(&1.coin))

    # Zip the two portfolios
    zipped_portfolios = Enum.zip(coinbase_portfolio, wazirx_portfolio)

    # Create %Coinbasewazirx{} struct with difference %
    Enum.map(zipped_portfolios, & create_coinbasewazirx_struct(&1))
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

  # Create %Coinbasewazirx{} struct and fills them
  defp create_coinbasewazirx_struct({coinbase_portfolio, wazirx_portfolio}) do
    %Coinbasewazirx{}
    |> struct(%{coin:             coinbase_portfolio.coin})
    |> struct(%{quote_currency:   wazirx_portfolio.quote_currency})
    |> struct(%{coinbase_price:   coinbase_portfolio.price_usd})
    |> struct(%{wazirx_bid_price: wazirx_portfolio.bid_price_inr})
    |> struct(%{bid_difference:   compute_difference(coinbase_portfolio.price_inr, wazirx_portfolio.bid_price_inr)})
    |> struct(%{wazirx_ask_price: wazirx_portfolio.ask_price_inr})
    |> struct(%{ask_difference:   compute_difference(coinbase_portfolio.price_inr, wazirx_portfolio.ask_price_inr)})
    |> struct(%{wazirx_volume:    wazirx_portfolio.volume})
  end

  # Compute difference %
  defp compute_difference(price1, price2) do
    (price2 - price1) / price1 * 100 |> Float.round(2)
  end
end
