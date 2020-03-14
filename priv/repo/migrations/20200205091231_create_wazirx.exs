defmodule Arbit.Repo.Migrations.CreateWazirx do
  use Ecto.Migration

  def change do
    create table(:wazirx) do
      add :coin,           :string
      add :quote_currency, :string
      add :bid_price_inr,  :float
      add :bid_price_usd,  :float
      add :bid_price_btc,  :float
      add :ask_price_inr,  :float
      add :ask_price_usd,  :float
      add :ask_price_btc,  :float
      add :volume,         :float

      timestamps()
    end

    create unique_index(:wazirx, [:coin, :quote_currency])
  end
end
