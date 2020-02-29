defmodule Arbit.Repo.Migrations.CreateCoinbasecoindcx do
  use Ecto.Migration

  def change do
    create table(:coinbasecoindcx) do
      add :coin,           :string
      add :quote_currency, :string
      add :coinbase_price, :float
      add :coindcx_price,  :float
      add :difference,     :float
      add :coindcx_volume, :float

      timestamps()
    end

    create unique_index(:coinbasecoindcx, [:coin, :quote_currency])
  end
end
