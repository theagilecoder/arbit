defmodule Arbit.Track.Currency do
  use Ecto.Schema
  import Ecto.Changeset

  schema "currencies" do
    field :amount, :float
    field :pair, :string

    timestamps()
  end

  @doc false
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, [:pair, :amount])
    |> validate_required([:pair, :amount])
  end

  @doc """
    Returns API URL
  """
  def url do
    "https://api.coinbase.com/v2/exchange-rates"
  end

  @doc """
    Calls API and returns currency conversion
  """
  def fetch_conversion do
    %{body: body} = HTTPoison.get! url()

    case Jason.decode!(body, [keys: :atoms]) do
      %{data: %{rates: %{INR: conversion}}} -> conversion |> String.to_float() |> Float.round(2)
      _ -> 0
    end
  end
end
