defmodule Arbit.Repo.Migrations.CreateCoinbase do
  use Ecto.Migration

  def change do
    create table(:coinbase) do
      add :product, :string
      add :price_usd, :float
      add :price_inr, :float

      timestamps()
    end

    create unique_index(:coinbase, [:product])
  end
end
