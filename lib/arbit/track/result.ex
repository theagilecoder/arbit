defmodule Arbit.Track.Result do

  use Ecto.Schema
  alias __MODULE__

  schema "results" do
    field :exchange1,  :string
    field :exchange2,  :string
    field :coin,       :string
    field :price1,     :float
    field :price2,     :float
    field :difference, :float

    timestamps()
  end
end
