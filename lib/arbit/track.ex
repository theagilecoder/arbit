defmodule Arbit.Track do
  @moduledoc """
  The Track context for calling Exchange APIs and storing in DB
  """

  import Ecto.Query, warn: false
  alias Arbit.Repo
  alias Arbit.Track.{Currency, Coinbase, Bitbns, Wazirx, Coindcx}

  #----------#
  # Currency #
  #----------#

  @doc """
  Upsert %Currency{} struct
  """
  def upsert_currency() do
    Currency.fetch_currency()
    |> Repo.insert(on_conflict: {:replace, [:amount, :updated_at]}, conflict_target: :pair)
  end

  @doc """
  Get conversion for a fiat pair
  """
  def get_conversion_amount(pair \\ "USD-INR") do
    %{amount: amount} = Repo.get_by!(Currency, %{pair: pair})
    amount
  end

  #----------#
  # Coinbase #
  #----------#

  @doc """
  Parallely upsert each %Coinbase{} struct in Coinbase table
  """
  def upsert_coinbase_portfolio() do
    Coinbase.fetch_portfolio()
    |> Task.async_stream(&Repo.insert(&1,
        on_conflict: {:replace, [:price_usd, :price_inr, :updated_at]},
        conflict_target: [:coin, :quote_currency]))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  @doc """
  Get all entries from Coinbase table
  """
  def list_coinbase, do: Repo.all(Coinbase)

  #--------#
  # Bitbns #
  #--------#

  @doc """
  Parallely upsert each %Bitbns{} struct in Bitbns table
  """
  def upsert_bitbns_portfolio() do
    Bitbns.fetch_portfolio()
    |> Task.async_stream(&Repo.insert(&1,
    on_conflict: {:replace, [:price_usd, :price_inr, :volume, :updated_at]},
    conflict_target: [:coin, :quote_currency]))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  @doc """
  Get all entries from Bitbns table
  """
  def list_bitbns, do: Repo.all(Bitbns)

  #--------#
  # Wazirx #
  #--------#

  @doc """
  Parallely upsert each %Wazirx{} struct in Wazirx table
  """
  def upsert_wazirx_portfolio() do
    Wazirx.fetch_portfolio()
    |> Task.async_stream(&Repo.insert(&1,
        on_conflict: {:replace, [:price_usd, :price_inr, :price_btc, :volume, :updated_at]},
        conflict_target: [:coin, :quote_currency]))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  @doc """
  Get all entries from Wazirx table
  """
  def list_wazirx, do: Repo.all(Wazirx)

  #---------#
  # Coindcx #
  #---------#

  @doc """
  Parallely upsert each %Coindcx{} struct in Coindcx table
  """
  def upsert_coindcx_portfolio() do
    Coindcx.fetch_portfolio()
    |> Task.async_stream(&Repo.insert(&1,
        on_conflict: {:replace, [:price_usd, :price_inr, :price_btc, :volume, :updated_at]},
        conflict_target: [:coin, :quote_currency]))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  @doc """
  Get all entries from Coindcx table
  """
  def list_coindcx, do: Repo.all(Coindcx)
end
