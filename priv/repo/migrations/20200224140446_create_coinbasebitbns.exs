defmodule Arbit.Repo.Migrations.CreateCoinbasebitbns do
  use Ecto.Migration

  def change do
    create table(:coinbasebitbns) do
      add :coin,             :string
      add :quote_currency,   :string
      add :coinbase_price,   :float
      add :bitbns_bid_price, :float
      add :bitbns_ask_price, :float
      add :bid_difference,   :float
      add :ask_difference,   :float
      add :bitbns_volume,    :float

      timestamps()
    end

    create unique_index(:coinbasebitbns, [:coin, :quote_currency])
  end
end
