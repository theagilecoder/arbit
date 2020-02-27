defmodule Arbit.Repo.Migrations.CreateCoinbasewazirx do
  use Ecto.Migration

  def change do
    create table(:coinbasewazirx) do
      add :coin,           :string
      add :quote_currency, :string
      add :coinbase_price, :float
      add :wazirx_price,   :float
      add :difference,     :float
      add :wazirx_volume,  :float

      timestamps()
    end

    create unique_index(:coinbasewazirx, [:coin, :quote_currency])
  end
end
