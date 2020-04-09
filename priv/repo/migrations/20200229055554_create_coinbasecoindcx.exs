defmodule Arbit.Repo.Migrations.CreateCoinbasecoindcx do
  use Ecto.Migration

  def change do
    create table(:coinbasecoindcx) do
      add :coin,              :string
      add :coinbase_quote,    :string
      add :coindcx_quote,     :string
      add :coinbase_price,    :float
      add :coindcx_bid_price, :float
      add :coindcx_ask_price, :float
      add :bid_difference,    :float
      add :ask_difference,    :float
      add :coindcx_volume,    :float

      timestamps()
    end

    create unique_index(:coinbasecoindcx, [:coin, :coinbase_quote, :coindcx_quote])
  end
end
