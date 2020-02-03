defmodule Arbit.Repo.Migrations.AddResultsTable do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :exchange1,  :string
      add :exchange2,  :string
      add :coin,       :string
      add :price1,     :float
      add :price2,     :float
      add :difference, :float

      timestamps()
    end

    create unique_index(:results, [:exchange1, :exchange2, :coin])
  end
end
