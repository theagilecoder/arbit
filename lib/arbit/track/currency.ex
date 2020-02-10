defmodule Arbit.Track.Currency do
  use Ecto.Schema

  schema "currencies" do
    field :amount, :float
    field :pair, :string

    timestamps()
  end


  @doc """
  Calls API and returns currency conversion
  """
  def fetch_currency() do
    %{data: %{rates: %{INR: conversion}}} = call_api()
    conversion |> String.to_float() |> Float.round(2)
  end

  defp url() do
    "https://api.coinbase.com/v2/exchange-rates"
  end

  defp call_api() do
    case HTTPoison.get(url()) do
      {:ok, %{status_code: 200, body: body}} -> Jason.decode!(body, [keys: :atoms])
      _                                      -> nil
    end
  end
end
