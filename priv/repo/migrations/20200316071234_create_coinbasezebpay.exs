defmodule Arbit.Repo.Migrations.CreateCoinbasezebpay do
  use Ecto.Migration

  def change do
    create table(:coinbasezebpay) do
      add :coin,             :string
      add :coinbase_quote,   :string
      add :zebpay_quote,     :string
      add :coinbase_price,   :float
      add :zebpay_bid_price, :float
      add :zebpay_ask_price, :float
      add :bid_difference,   :float
      add :ask_difference,   :float
      add :zebpay_volume,    :float

      timestamps()
    end

    create unique_index(:coinbasezebpay, [:coin, :coinbase_quote, :zebpay_quote])
  end
end
