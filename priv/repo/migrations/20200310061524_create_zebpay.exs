defmodule Arbit.Repo.Migrations.CreateZebpay do
  use Ecto.Migration

  def change do
    create table(:zebpay) do
      add :coin,           :string
      add :quote_currency, :string
      add :price_inr,      :float
      add :price_usd,      :float
      add :price_btc,      :float
      add :volume,         :float

      timestamps()
    end

    create unique_index(:zebpay, [:coin, :quote_currency])
  end
end
