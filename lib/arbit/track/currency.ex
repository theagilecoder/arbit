defmodule Arbit.Track.Currency do
  @moduledoc """
  The Currency module call API to get Fiat currency conversion
  """
  use Ecto.Schema
  alias __MODULE__

  schema "currencies" do
    field :amount, :float
    field :pair, :string

    timestamps()
  end

  @doc """
    Returns %Currency{} struct
  """
  def fetch_currency() do
    # Call api and process JSON to get conversion
    %{body: body} = HTTPoison.get!(url())
    body = Jason.decode!(body, keys: :atoms)
    %{data: %{rates: %{INR: conversion}}} = body
    conversion = conversion |> String.to_float() |> Float.round(2)

    # Create %Currency{} struct
    %Currency{}
    |> struct(%{pair: "USD-INR"})
    |> struct(%{amount: conversion})
  end

  defp url do
    "https://api.coinbase.com/v2/exchange-rates?currency=USD"
  end
end
