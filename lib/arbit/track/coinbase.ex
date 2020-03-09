defmodule Arbit.Track.Coinbase do
  @moduledoc """
  This module calls Pro Coinbase APIs and prepares list of %Coinbase{} structs
  Pro Coinbase has a rate limit of 3 requests per second
  """

  use Ecto.Schema
  alias Arbit.Track
  alias __MODULE__

  schema "coinbase" do
    field :coin,           :string
    field :quote_currency, :string
    field :price_usd,      :float
    field :price_inr,      :float
    field :price_btc,      :float

    timestamps()
  end

  @doc """
    Returns list of %Coinbase{} structs with all fields filled
  """
  def fetch_portfolio do
    conversion_amount = Track.get_conversion_amount("USD-INR")

    get_all_pairs()
    |> filter_relevant_pairs()
    |> Enum.map(&get_price_and_create_struct(&1))
    |> Enum.map(&fill_blank_price_inr(&1, conversion_amount))

  end

  defp get_all_pairs() do
    %{body: body} = HTTPoison.get! "https://api.pro.coinbase.com/products"
    Jason.decode!(body, [keys: :atoms])
  end

  defp filter_relevant_pairs(pairs) do
    pairs
    |> Enum.filter(& &1.quote_currency in ["USD", "BTC"])
    |> Enum.map(& &1.id)
  end

  defp get_price_and_create_struct(pair) do
    %{body: body} = HTTPoison.get! "https://api.pro.coinbase.com/products/#{pair}/ticker"
    body = Jason.decode!(body, [keys: :atoms])
    coin = String.split(pair, "-") |> Enum.at(0)
    quote_currency = String.split(pair, "-") |> Enum.at(1)

    :timer.sleep(400)

    %Coinbase{}
    |> struct(%{coin: coin})
    |> struct(%{quote_currency: quote_currency})
    |> struct(%{price_usd: (if quote_currency == "USD", do: body.price |> Float.parse() |> elem(0), else: nil)})
    |> struct(%{price_btc: (if quote_currency == "BTC", do: body.price |> Float.parse() |> elem(0), else: nil)})
  end

  defp fill_blank_price_inr(%Coinbase{price_usd: price_usd} = coin, conversion_amount) do
    cond do
      price_usd != nil -> struct(coin, %{price_inr: price_usd * conversion_amount})
      true             -> coin
    end
  end
end
