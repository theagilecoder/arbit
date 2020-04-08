defmodule Arbit.Repo.Migrations.CreateBinancebitbns do
  use Ecto.Migration

  def change do
    create table(:binancebitbns) do
      add :coin,             :string
      add :binance_quote,    :string
      add :bitbns_quote,     :string
      add :binance_price,    :float
      add :bitbns_bid_price, :float
      add :bitbns_ask_price, :float
      add :bid_difference,   :float
      add :ask_difference,   :float
      add :bitbns_volume,    :float

      timestamps()
    end

    create unique_index(:binancebitbns, [:coin, :binance_quote, :bitbns_quote])
  end
end
