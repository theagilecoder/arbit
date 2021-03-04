defmodule Arbit.Track.Bitbns do
  @moduledoc """
  This module calls Bitbns API and prepares list of %Bitbns{} structs
  """

  use Ecto.Schema
  alias Arbit.Track
  alias __MODULE__

  schema "bitbns" do
    field :coin,           :string
    field :quote_currency, :string
    field :bid_price_usd,  :float
    field :bid_price_inr,  :float
    field :ask_price_usd,  :float
    field :ask_price_inr,  :float
    field :volume,         :float

    timestamps()
  end

  @doc """
  Returns list of %Bitbns{} structs with all fields filled.
  """
  def fetch_portfolio do
    conversion_amount = Track.get_conversion_amount("USD-INR")

    product_list()
    |> filter_relevant_pairs()
    |> Enum.map(&create_bitbns_struct/1)
    |> Enum.reject(&(&1.volume == 0.0))
    |> Enum.map(&fill_blank_bid_price_usd(&1, conversion_amount))
    |> Enum.map(&fill_blank_bid_price_inr(&1, conversion_amount))
    |> Enum.map(&fill_blank_ask_price_usd(&1, conversion_amount))
    |> Enum.map(&fill_blank_ask_price_inr(&1, conversion_amount))
  end

  defp product_list do
    %{body: body} = HTTPoison.get! url()
    Jason.decode!(body, [keys: :atoms])
    # |> Map.keys() |> Enum.sort() |> IO.inspect(limit: :infinity, width: 0)
  end

  defp url do
    "https://bitbns.com/order/getTickerWithVolume/"
  end

  # Track only INR pairs and ignore USDT pairs
  # Accepts a list of coin pairs where each pair is a map
  # Returns a list of coin pairs
  defp filter_relevant_pairs(pairs) do
    pairs
    |> Enum.filter(fn {key, _value} -> detect_quote_currency(key) in ["INR"] end)
  end

  defp create_bitbns_struct({key, value}) do
    case value do
      %{highest_buy_bid: bid, lowest_sell_bid: ask, volume: %{volume: volume}} ->
        %Bitbns{}
        |> struct(%{coin: sanitize_name(key)})
        |> struct(%{quote_currency: detect_quote_currency(key)})
        |> struct(assign_bid_price(key, bid/1))
        |> struct(assign_ask_price(key, ask/1))
        |> struct(%{volume: volume/1})

      %{highest_buy_bid: bid, lowest_sell_bid: ask} ->
        %Bitbns{}
        |> struct(%{coin: sanitize_name(key)})
        |> struct(%{quote_currency: detect_quote_currency(key)})
        |> struct(assign_bid_price(key, bid/1))
        |> struct(assign_ask_price(key, ask/1))
        |> struct(%{volume: 0.0})

      _ ->
        %Bitbns{}
        |> struct(%{coin: sanitize_name(key)})
        |> struct(%{quote_currency: detect_quote_currency(key)})
        |> struct(%{bid_price_inr: 0.0})
        |> struct(%{bid_price_usd: 0.0})
        |> struct(%{volume: 0.0})
    end
  end

  defp detect_quote_currency(key) do
    key = to_string(key)
    cond do
      key == "USDT"                 -> "INR"
      String.contains?(key, "USDT") -> "USDT"
      true                          -> "INR"
    end
  end

  defp sanitize_name(key) do
    key = to_string(key)
    cond do
      key == "USDT"                 -> "USDT"
      String.contains?(key, "USDT") -> String.replace_trailing(key, "USDT", "")
      true                          -> key
    end
  end

  defp assign_bid_price(key, price) do
    key = to_string(key)
    cond do
      String.contains?(key, "USDT") -> %{bid_price_usd: price |> Float.round(6)}
      true                          -> %{bid_price_inr: price |> Float.round(6)}
    end
  end

  defp assign_ask_price(key, price) do
    key = to_string(key)
    cond do
      String.contains?(key, "USDT") -> %{ask_price_usd: price |> Float.round(6)}
      true                          -> %{ask_price_inr: price |> Float.round(6)}
    end
  end

  defp fill_blank_bid_price_usd(%Bitbns{bid_price_inr: bid_price_inr} = coin, conversion_amount) do
    cond do
      bid_price_inr != nil -> struct(coin, %{bid_price_usd: bid_price_inr / conversion_amount |> Float.round(6)})
      true                 -> coin
    end
  end

  defp fill_blank_bid_price_inr(%Bitbns{bid_price_usd: bid_price_usd} = coin, conversion_amount) do
    cond do
      bid_price_usd != nil -> struct(coin, %{bid_price_inr: bid_price_usd * conversion_amount |> Float.round(6)})
      true                 -> coin
    end
  end

  defp fill_blank_ask_price_usd(%Bitbns{ask_price_inr: ask_price_inr} = coin, conversion_amount) do
    cond do
      ask_price_inr != nil -> struct(coin, %{ask_price_usd: ask_price_inr / conversion_amount |> Float.round(6)})
      true                 -> coin
    end
  end

  defp fill_blank_ask_price_inr(%Bitbns{ask_price_usd: ask_price_usd} = coin, conversion_amount) do
    cond do
      ask_price_usd != nil -> struct(coin, %{ask_price_inr: ask_price_usd * conversion_amount |> Float.round(6)})
      true                 -> coin
    end
  end
end
