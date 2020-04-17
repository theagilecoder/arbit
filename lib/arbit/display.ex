defmodule Arbit.Display do
  @moduledoc """
  The Display context is responsible for
  storing arbitrage results in DB
  so that it can be displayed on the results pages
  """

  import Ecto.Query, warn: false
  alias Arbit.Repo
  alias Arbit.Display.{Coinbasebitbns, Coinbasewazirx, Coinbasecoindcx, Coinbasezebpay, Binancebitbns, Dashboard}

  #-------------------#
  # Coinbase - Bitbns #
  #-------------------#

  @doc """
  Upserts results in coinbasebitbns table
  """
  def upsert_coinbasebitbns do
    Repo.delete_all(Coinbasebitbns)
    Repo.insert_all(Coinbasebitbns, Coinbasebitbns.compute_arbitrage() |> prepare_for_insert_all())
  end

  @doc """
    Display all results from coinbasebitbns table
  """
  def list_coinbasebitbns, do: Repo.all(Coinbasebitbns)

  #-------------------#
  # Coinbase - WazirX #
  #-------------------#

  @doc """
  Upserts results in coinbasewazirx table
  """
  def upsert_coinbasewazirx do
    Repo.delete_all(Coinbasewazirx)
    Repo.insert_all(Coinbasewazirx, Coinbasewazirx.compute_arbitrage() |> prepare_for_insert_all())
  end

  @doc """
    Display all results in coinbasewazirx table
  """
  def list_coinbasewazirx, do: Repo.all(Coinbasewazirx)

  #--------------------#
  # Coinbase - CoinDCX #
  #--------------------#

  @doc """
  Upserts results in coinbasecoindcx table
  """
  def upsert_coinbasecoindcx do
    Repo.delete_all(Coinbasecoindcx)
    Repo.insert_all(Coinbasecoindcx, Coinbasecoindcx.compute_arbitrage() |> prepare_for_insert_all())
  end

  @doc """
    Display all results in coinbasecoindcx table
  """
  def list_coinbasecoindcx, do: Repo.all(Coinbasecoindcx)

  #-------------------#
  # Coinbase - Zebpay #
  #-------------------#

  @doc """
  Upserts results in coinbasezebpay table
  """
  def upsert_coinbasezebpay do
    Repo.delete_all(Coinbasezebpay)
    Repo.insert_all(Coinbasezebpay, Coinbasezebpay.compute_arbitrage() |> prepare_for_insert_all())
  end

  @doc """
    Display all results in coinbasezebpay table
  """
  def list_coinbasezebpay, do: Repo.all(Coinbasezebpay)

  #------------------#
  # Binance - Bitbns #
  #------------------#

  @doc """
  Upserts results in binancebitbns table
  """
  def upsert_binancebitbns do
    Repo.delete_all(Binancebitbns)
    Repo.insert_all(Binancebitbns, Binancebitbns.compute_arbitrage() |> prepare_for_insert_all())
  end

  @doc """
    Display all results in binancebitbns table
  """
  def list_binancebitbns, do: Repo.all(Binancebitbns)

  #-----------#
  # Dashboard #
  #-----------#

  @doc """
  Upserts in dashboard table
  """
  def upsert_dashboard do
    Repo.delete_all(Dashboard)
    Repo.insert_all(Dashboard, Dashboard.collect_all_results() |> prepare_for_insert_all())
  end

  @doc """
    Display all results in dashboard table
  """
  def list_dashboard, do: Repo.all(Dashboard)

  #---------#
  # Helpers #
  #---------#

  @doc """
  Receives a list of schema structs where each struct is a coin pair
  and returns a list of maps where each map is a sanitized coin pair
  """
  def prepare_for_insert_all(list_of_structs) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    list_of_structs
    |> Enum.map(fn x ->
      x
      |> Map.from_struct()
      |> Map.drop([:__meta__, :id])
      |> Map.merge(%{inserted_at: now, updated_at: now})
    end)
  end
end
