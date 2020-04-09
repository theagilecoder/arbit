defmodule Arbit.Repo.Migrations.CreateCoinbasewazirx do
  use Ecto.Migration

  def change do
    create table(:coinbasewazirx) do
      add :coin,             :string
      add :coinbase_quote,   :string
      add :wazirx_quote,     :string
      add :coinbase_price,   :float
      add :wazirx_bid_price, :float
      add :wazirx_ask_price, :float
      add :bid_difference,   :float
      add :ask_difference,   :float
      add :wazirx_volume,    :float

      timestamps()
    end

    create unique_index(:coinbasewazirx, [:coin, :coinbase_quote, :wazirx_quote])
  end
end
