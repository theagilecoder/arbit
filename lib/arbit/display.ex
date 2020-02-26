defmodule Arbit.Display do
  @moduledoc """
  The Display context for storing results in DB
  so that it can be displayed on the results pages
  """

  import Ecto.Query, warn: false
  alias Arbit.Repo
  alias Arbit.Display.{Coinbasebitbns}

  @doc """
  Upserts results in coinbasebitbns table
  """
  def upsert_coinbasebitbns do
    Coinbasebitbns.compute_arbitrage()
    |> Task.async_stream(&Repo.insert(&1,
        on_conflict: {:replace, [:coinbase_price, :bitbns_price, :bitbns_volume, :difference, :updated_at]},
        conflict_target: [:coin, :quote_currency]))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  @doc """
    Display results
  """
  def list_coinbasebitbns, do: Repo.all(Coinbasebitbns)
end
