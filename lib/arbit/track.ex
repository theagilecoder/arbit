defmodule Arbit.Track do
  @moduledoc """
  The Track context for calling Exchange APIs and storing in DB
  """

  import Ecto.Query, warn: false
  alias Arbit.Repo
  alias Arbit.Track.{Currency, Coinbase, Bitbns, Wazirx}

  ############
  #  Wazirx  #
  ############

  def upsert_wazirx_portfolio() do
    Wazirx.fetch_portfolio()
    |> Task.async_stream(&Repo.insert(&1, on_conflict: {:replace, [:price_usd, :price_inr, :updated_at]}, conflict_target: :product))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  def get_wazirx_product(product) do
    Repo.get_by(Wazirx, %{product: product})
  end

  ############
  #  Bitbns  #
  ############

  @doc """
  Parallely upsert each coin struct in bitbns table
  """
  def upsert_bitbns_portfolio() do
    Bitbns.fetch_portfolio()
    |> Task.async_stream(&Repo.insert(&1, on_conflict: {:replace, [:price_usd, :price_inr, :volume, :updated_at]}, conflict_target: [:coin, :quote_currency]))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  def list_bitbns, do: Repo.all(Bitbns)

  def get_bitbns_product(product) do
    Repo.get_by(Bitbns, %{product: product})
  end

  #############
  #  Coinbase #
  #############

  @doc """
  Parallely upsert each coin struct in coinbase table
  """
  def upsert_coinbase_portfolio() do
    Coinbase.fetch_portfolio()
    |> Task.async_stream(&Repo.insert(&1, on_conflict: {:replace, [:price_usd, :price_inr, :updated_at]}, conflict_target: [:coin, :quote_currency]))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  def list_coinbase, do: Repo.all(Coinbase)

  ####################
  #     Currency     #
  ####################

  def upsert_currency() do
    %Currency{}
    |> struct(%{pair: "USD-INR"})  # Merge map into Currency struct
    |> struct(%{amount: Currency.fetch_currency()})
    |> Repo.insert(on_conflict: {:replace, [:amount, :updated_at]}, conflict_target: :pair)
  end

  def get_conversion_amount(pair) do
    %{amount: amount} = Repo.get_by!(Currency, %{pair: pair})
    amount
  end
end
