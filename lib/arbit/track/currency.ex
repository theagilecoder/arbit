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
    base_url = "http://apilayer.net/api/live"
    access_key = Application.get_env(:arbit, :CURRENCY_LAYER_API_KEY)
    source = "USD"
    currencies = "INR"

    "#{base_url}?access_key=#{access_key}&source=#{source}&currencies=#{currencies}"
  end

  @doc """
    Calls API and returns currency conversion
  """
  def fetch_conversion do
    %{body: body} = HTTPoison.get! url()
    %{quotes: %{USDINR: conversion}} = Jason.decode!(body, [keys: :atoms])
    Float.round(conversion, 2)
  end
end
