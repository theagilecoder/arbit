defmodule Arbit.Track do
  @moduledoc """
  The Track context for calling Exchange APIs and storing in DB
  """

  import Ecto.Query, warn: false
  alias Arbit.Repo
  alias Arbit.Track.{Currency, Coinbase, Bitbns, Wazirx, Coindcx, Zebpay, Binance}

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
  Insert each %Coinbase{} struct in Coinbase table
  """
  def upsert_coinbase_portfolio() do
    Repo.delete_all(Coinbase)
    Repo.insert_all(Coinbase, Coinbase.fetch_portfolio() |> prepare_for_insert_all())
  end

  @doc """
  Get all entries from Coinbase table
  """
  def list_coinbase, do: Repo.all(Coinbase)

  #--------#
  # Bitbns #
  #--------#

  @doc """
  Insert each %Bitbns{} struct in Bitbns table
  """
  def upsert_bitbns_portfolio() do
    Repo.delete_all(Bitbns)
    Repo.insert_all(Bitbns, Bitbns.fetch_portfolio() |> prepare_for_insert_all())
  end

  @doc """
  Get all entries from Bitbns table
  """
  def list_bitbns, do: Repo.all(Bitbns)

  #--------#
  # Wazirx #
  #--------#

  @doc """
  Insert each %Wazirx{} struct in Wazirx table
  """
  def upsert_wazirx_portfolio() do
    Repo.delete_all(Wazirx)
    Repo.insert_all(Wazirx, Wazirx.fetch_portfolio() |> prepare_for_insert_all())
  end

  @doc """
  Get all entries from Wazirx table
  """
  def list_wazirx, do: Repo.all(Wazirx)

  #---------#
  # Coindcx #
  #---------#

  @doc """
  Insert each %Coindcx{} struct in Coindcx table
  """
  def upsert_coindcx_portfolio() do
    Repo.delete_all(Coindcx)
    Repo.insert_all(Coindcx, Coindcx.fetch_portfolio() |> prepare_for_insert_all())
  end

  @doc """
  Get all entries from Coindcx table
  """
  def list_coindcx, do: Repo.all(Coindcx)

  #--------#
  # Zebpay #
  #--------#

  @doc """
  Inserts each %Zebpay{} struct in Zebpay table
  """
  def upsert_zebpay_portfolio() do
    Repo.delete_all(Zebpay)
    Repo.insert_all(Zebpay, Zebpay.fetch_portfolio() |> prepare_for_insert_all())
  end

  @doc """
  Get all entries from Zebpay table
  """
  def list_zebpay, do: Repo.all(Zebpay)

  #---------#
  # Binance #
  #---------#

  @doc """
  Insert each %Binance{} struct in Zebpay table
  """
  def upsert_binance_portfolio() do
    Repo.delete_all(Binance)
    Repo.insert_all(Binance, Binance.fetch_portfolio() |> prepare_for_insert_all())
  end

  @doc """
  Get all entries from Binance table
  """
  def list_binance, do: Repo.all(Binance)

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
