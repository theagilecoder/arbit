defmodule Arbit.Repo.Migrations.CreateBinance do
  use Ecto.Migration

  def change do
    create table(:binance) do
      add :coin,           :string
      add :quote_currency, :string
      add :price_usd,      :float
      add :price_inr,      :float
      add :price_btc,      :float

      timestamps()
    end

    create unique_index(:binance, [:coin, :quote_currency])
  end
end
