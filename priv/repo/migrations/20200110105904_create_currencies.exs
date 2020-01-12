defmodule Arbit.Repo.Migrations.CreateCurrencies do
  use Ecto.Migration

  def change do
    create table(:currencies) do
      add :pair, :string
      add :amount, :float

      timestamps()
    end

    create unique_index(:currencies, [:pair])
  end
end
