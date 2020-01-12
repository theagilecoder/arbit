defmodule Arbit.Track do
  @moduledoc """
  The Track context.
  """

  import Ecto.Query, warn: false
  alias Arbit.Repo

  alias Arbit.Track.Currency
  alias Arbit.Track.Coinbase

  ############
  # Uses API #
  ############

  def upsert_conversion do
    %Currency{}
    |> struct(%{pair: "USDINR", amount: Currency.fetch_conversion})  # Merge map into Currency struct
    |> Repo.insert(on_conflict: {:replace, [:amount, :updated_at]}, conflict_target: :pair)
  end

  def upsert_coinbase do
    price_usd = Coinbase.fetch_price()
    price_inr = (price_usd * get_conversion_amount("USDINR")) |> Float.round(2)

    %Coinbase{}
    |> struct(%{product: "BTC-USD"})
    |> struct(%{price_usd: price_usd})
    |> struct(%{price_inr: price_inr})
    |> Repo.insert(on_conflict: {:replace, [:price_usd, :price_inr, :updated_at]}, conflict_target: :product)
  end

  ####################
  # Uses CLI Currency#
  ####################

  def list_currencies,          do: Repo.all(Currency)

  def get_currency!(id),        do: Repo.get!(Currency, id)

  def get_currency_by!(params), do: Repo.get_by!(Currency, params)

  def get_conversion_amount(pair) do
    %{amount: amount} = get_currency_by!(%{pair: pair})
    amount
  end

  def create_currency(attrs) do
    %Currency{}
    |> struct(attrs)  # Merge map into Currency struct
    |> Repo.insert(on_conflict: {:replace, [:amount, :updated_at]}, conflict_target: :pair)
  end

  def delete_currency(%Currency{} = currency) do
    Repo.delete(currency)
  end

  ####################
  # Uses CLI Coinbase#
  ####################

  def create_coinbase(attrs) do
    %Coinbase{}
    |> struct(attrs)  # Merge map into Currency struct
    |> Repo.insert(on_conflict: {:replace, [:price_usd, :updated_at]}, conflict_target: :product)
  end

end
