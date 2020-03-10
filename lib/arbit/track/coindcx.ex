defmodule Arbit.Track.Coindcx do
  @moduledoc """
  This module calls CoinDCX API and prepares list of %Coindcx{} structs
  """

  use Ecto.Schema
  alias Arbit.Track
  alias __MODULE__

  schema "coindcx" do
    field :coin,           :string
    field :quote_currency, :string
    field :price_usd,      :float
    field :price_inr,      :float
    field :price_btc,      :float
    field :volume,         :float

    timestamps()
  end

  @doc """
  Returns list of %Coindcx{} structs with all fields filled.
  """
  def fetch_portfolio do
    conversion_amount = Track.get_conversion_amount("USD-INR")

    product_list()
    |> remove_bad_entries()
    |> Enum.map(&create_coindcx_struct/1)
    |> Enum.map(&fill_blank_price_usd(&1, conversion_amount))
    |> Enum.map(&fill_blank_price_inr(&1, conversion_amount))
  end

  defp product_list do
    %{body: body} = HTTPoison.get! url()
    Jason.decode!(body, [keys: :atoms])
    # |> Map.keys() |> Enum.sort() |> IO.inspect(limit: :infinity, width: 0)
  end

  defp url do
    "https://api.coindcx.com/exchange/ticker"
  end

  # Remove entries with no volume key or nil bid value or bid value in e-notation
  defp remove_bad_entries(list) do
    list
    |> Enum.filter(fn x -> Map.has_key?(x, :volume) end)
    |> Enum.reject(fn x -> x.bid == nil end)
    |> Enum.reject(fn x -> String.contains?(x.bid, "e") end)
  end

  # Convert a map to a %Coindcx{} struct
  defp create_coindcx_struct(coin_map) do
    %Coindcx{}
    |> struct!(%{coin: sanitize_name(coin_map.market)})
    |> struct!(%{quote_currency: detect_quote_currency(coin_map.market)})
    |> struct!(%{volume: coin_map.volume |> Float.parse() |> elem(0)})
    |> struct!(assign_price(coin_map.market, coin_map.bid))
  end

  defp detect_quote_currency(market) do
    cond do
      String.ends_with?(market, "INR")  -> "INR"
      String.ends_with?(market, "BTC")  -> "BTC"
      String.ends_with?(market, "USDT") -> "USDT"
      String.ends_with?(market, "BNB")  -> "BNB"
      String.ends_with?(market, "TUSD") -> "TUSD"
      String.ends_with?(market, "XRP")  -> "XRP"
      String.ends_with?(market, "USDC") -> "USDC"
      String.ends_with?(market, "ETH")  -> "ETH"
      true                              -> market
    end
  end

  defp sanitize_name(market) do
    cond do
      String.ends_with?(market, "INR")  -> String.replace_trailing(market, "INR", "")
      String.ends_with?(market, "BTC")  -> String.replace_trailing(market, "BTC", "")
      String.ends_with?(market, "USDT") -> String.replace_trailing(market, "USDT", "")
      String.ends_with?(market, "BNB")  -> String.replace_trailing(market, "BNB", "")
      String.ends_with?(market, "TUSD") -> String.replace_trailing(market, "TUSD", "")
      String.ends_with?(market, "XRP")  -> String.replace_trailing(market, "XRP", "")
      String.ends_with?(market, "USDC") -> String.replace_trailing(market, "USDC", "")
      String.ends_with?(market, "ETH")  -> String.replace_trailing(market, "ETH", "")
      true                              -> market
    end
  end

  defp assign_price(market, bid) do
    cond do
      String.ends_with?(market, "INR")  -> %{price_inr: bid |> Float.parse() |> elem(0)}
      String.ends_with?(market, "BTC")  -> %{price_btc: bid |> Float.parse() |> elem(0)}
      String.ends_with?(market, "USDT") -> %{price_usd: bid |> Float.parse() |> elem(0)}
      String.ends_with?(market, "TUSD") -> %{price_usd: bid |> Float.parse() |> elem(0)}
      String.ends_with?(market, "USDC") -> %{price_usd: bid |> Float.parse() |> elem(0)}
      true                              -> %{price_inr: nil}
    end
  end

  defp fill_blank_price_usd(%Coindcx{price_inr: price_inr} = coin, conversion_amount) do
    cond do
      price_inr != nil -> struct(coin, %{price_usd: price_inr / conversion_amount })
      true             -> coin
    end
  end

  defp fill_blank_price_inr(%Coindcx{price_usd: price_usd} = coin, conversion_amount) do
    cond do
      price_usd != nil -> struct(coin, %{price_inr: price_usd * conversion_amount })
      true             -> coin
    end
  end
end
