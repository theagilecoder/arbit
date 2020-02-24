defmodule Arbit.Repo.Migrations.CreateBitbns do
  use Ecto.Migration

  def change do
    create table(:bitbns) do
      add :product,        :string
      add :quote_currency, :string
      add :price_inr,      :float
      add :price_usd,      :float
      add :volume,         :float

      timestamps()
    end

    create unique_index(:bitbns, [:product, :quote_currency])
  end
end
