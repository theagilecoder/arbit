defmodule Arbit.Repo.Migrations.CreateWazirx do
  use Ecto.Migration

  def change do
    create table(:wazirx) do
      add :product,   :string
      add :price_inr, :float
      add :price_usd, :float

      timestamps()
    end

    create unique_index(:wazirx, [:product])
  end
end
