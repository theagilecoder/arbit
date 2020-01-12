defmodule Arbit.Track do
  @moduledoc """
  The Track context.
  """

  import Ecto.Query, warn: false
  alias Arbit.Repo

  alias Arbit.Track.Currency

  ############
  # Uses API #
  ############

  def upsert_conversion do
    %Currency{}
    |> struct(%{pair: "USDINR", amount: Currency.fetch_conversion})  # Merge map into Currency struct
    |> Repo.insert(on_conflict: {:replace, [:amount, :updated_at]}, conflict_target: :pair)
  end

  ############
  # Uses CLI #
  ############

  def list_currencies,          do: Repo.all(Currency)

  def get_currency!(id),        do: Repo.get!(Currency, id)

  def get_currency_by!(params), do: Repo.get_by!(Currency, params)

  def create_currency(attrs) do
    %Currency{}
    |> struct(attrs)  # Merge map into Currency struct
    |> Repo.insert(on_conflict: {:replace, [:amount, :updated_at]}, conflict_target: :pair)
  end

  def delete_currency(%Currency{} = currency) do
    Repo.delete(currency)
  end
end
