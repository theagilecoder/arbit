defmodule Arbit.Repo.Migrations.CreateDashboard do
  use Ecto.Migration

  def change do
    create table(:dashboard) do
      add :coin,           :string
      add :ex1,            :string
      add :ex1_quote,      :string
      add :ex1_price,      :float
      add :ex2,            :string
      add :ex2_quote,      :string
      add :ex2_bid_price,  :float
      add :ex2_ask_price,  :float
      add :bid_difference, :float
      add :ask_difference, :float
      add :ex2_volume,     :float

      timestamps()
    end
  end
end
