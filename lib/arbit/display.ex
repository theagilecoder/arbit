defmodule Arbit.Display do
  @moduledoc """
  The Display context is responsible for
  storing arbitrage results in DB
  so that it can be displayed on the results pages
  """

  import Ecto.Query, warn: false
  alias Arbit.Repo
  alias Arbit.Display.{Coinbasebitbns, Coinbasewazirx, Coinbasecoindcx, Coinbasezebpay, Binancebitbns}

  #-------------------#
  # Coinbase - Bitbns #
  #-------------------#

  @doc """
  Upserts results in coinbasebitbns table
  """
  def upsert_coinbasebitbns do
    Coinbasebitbns.compute_arbitrage()
    |> Task.async_stream(&Repo.insert(&1,
        on_conflict: {:replace, [:coinbase_price, :bitbns_bid_price, :bitbns_ask_price, :bitbns_volume, :bid_difference, :ask_difference, :updated_at]},
        conflict_target: [:coin, :quote_currency]))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  @doc """
    Display all results
  """
  def list_coinbasebitbns, do: Repo.all(Coinbasebitbns)

  #-------------------#
  # Coinbase - WazirX #
  #-------------------#

  @doc """
  Upserts results in coinbasewazirx table
  """
  def upsert_coinbasewazirx do
    Coinbasewazirx.compute_arbitrage()
    |> Task.async_stream(&Repo.insert(&1,
        on_conflict: {:replace, [:coinbase_price, :wazirx_bid_price, :wazirx_ask_price, :wazirx_volume, :bid_difference, :ask_difference, :updated_at]},
        conflict_target: [:coin, :quote_currency]))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  @doc """
    Display all results
  """
  def list_coinbasewazirx, do: Repo.all(Coinbasewazirx)

  #--------------------#
  # Coinbase - CoinDCX #
  #--------------------#

  @doc """
  Upserts results in coinbasecoindcx table
  """
  def upsert_coinbasecoindcx do
    Coinbasecoindcx.compute_arbitrage()
    |> Task.async_stream(&Repo.insert(&1,
        on_conflict: {:replace, [:coinbase_price, :coindcx_bid_price, :coindcx_ask_price, :coindcx_volume, :bid_difference, :ask_difference, :updated_at]},
        conflict_target: [:coin, :coindcx_quote, :coinbase_quote]))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  @doc """
    Display all results
  """
  def list_coinbasecoindcx, do: Repo.all(Coinbasecoindcx)

  #-------------------#
  # Coinbase - Zebpay #
  #-------------------#

  @doc """
  Upserts results in coinbasezebpay table
  """
  def upsert_coinbasezebpay do
    Coinbasezebpay.compute_arbitrage()
    |> Task.async_stream(&Repo.insert(&1,
        on_conflict: {:replace, [:coinbase_price, :zebpay_bid_price, :zebpay_ask_price, :zebpay_volume, :bid_difference, :ask_difference, :updated_at]},
        conflict_target: [:coin, :zebpay_quote, :coinbase_quote]))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  @doc """
    Display all results
  """
  def list_coinbasezebpay, do: Repo.all(Coinbasezebpay)

  #------------------#
  # Binance - Bitbns #
  #------------------#

  @doc """
  Upserts results in binancebitbns table
  """
  def upsert_binancebitbns do
    Binancebitbns.compute_arbitrage()
    |> Task.async_stream(&Repo.insert(&1,
        on_conflict: {:replace, [:binance_price, :bitbns_bid_price, :bitbns_ask_price, :bitbns_volume, :bid_difference, :ask_difference, :updated_at]},
        conflict_target: [:coin, :binance_quote, :bitbns_quote]))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  @doc """
    Display all results
  """
  def list_binancebitbns, do: Repo.all(Binancebitbns)
end
