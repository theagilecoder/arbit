defmodule Arbit.Repo.Migrations.CreateCoinbase do
  use Ecto.Migration

  def change do
    create table(:coinbase) do
      add :coin,           :string
      add :quote_currency, :string
      add :price_usd,      :float
      add :price_inr,      :float
      add :price_btc,      :float

      timestamps()
    end

    create unique_index(:coinbase, [:coin, :quote_currency])
  end
end
