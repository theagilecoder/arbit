defmodule Arbit.Track do
  @moduledoc """
  The Track context.
  """

  import Ecto.Query, warn: false
  alias Arbit.Repo

  alias Arbit.Track.{Currency, Coinbase, Bitbns, Wazirx, Result}

  ############
  #  Result  #
  ############

  def upsert_results() do
    Result.compute_results("Coinbase", "Bitbns")
    |> Task.async_stream(&Repo.insert(&1, on_conflict: {:replace, [:price1, :price2, :difference, :updated_at]}, conflict_target: [:exchange1, :exchange2, :coin]))
    |> Enum.map(fn {:ok, result} -> result end)

    Result.compute_results("Coinbase", "Wazirx")
    |> Task.async_stream(&Repo.insert(&1, on_conflict: {:replace, [:price1, :price2, :difference, :updated_at]}, conflict_target: [:exchange1, :exchange2, :coin]))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  def list_results do
    Repo.all(Result)
  end

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
    |> Task.async_stream(&Repo.insert(&1, on_conflict: {:replace, [:price_usd, :price_inr, :volume, :updated_at]}, conflict_target: [:product, :quote_currency]))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  def get_bitbns_product(product) do
    Repo.get_by(Bitbns, %{product: product})
  end

  #############
  #  Coinbase #
  #############

  def upsert_coinbase_portfolio() do
    conversion_amount = get_conversion_amount("USD-INR")

    # Merge price_inr in each product in the portfolio
    # & Parallely upsert each product in coinbase table
    Coinbase.fetch_portfolio()
    |> Enum.map(fn %{price_usd: price_usd} = product -> struct!(product, %{price_inr: (price_usd * conversion_amount) |> Float.round(2)}) end)
    |> Task.async_stream(&Repo.insert(&1, on_conflict: {:replace, [:price_usd, :price_inr, :updated_at]}, conflict_target: :product))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  def create_coinbase(attrs) do
    %Coinbase{}
    |> struct(attrs)  # Merge map into Currency struct
    |> Repo.insert(on_conflict: {:replace, [:price_usd, :updated_at]}, conflict_target: :product)
  end

  def list_coinbase,            do: Repo.all(Coinbase)

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
