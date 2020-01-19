defmodule Arbit.Repo.Migrations.CreateBitbns do
  use Ecto.Migration

  def change do
    create table(:bitbns) do
      add :product, :string
      add :price_inr, :float
      add :price_usd, :float

      timestamps()
    end

    create unique_index(:bitbns, [:product])
  end
end
