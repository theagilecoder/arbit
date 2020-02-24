defmodule Arbit.Track.Bitbns do
  use Ecto.Schema
  alias Arbit.Track
  alias __MODULE__

  schema "bitbns" do
    field :product,        :string
    field :quote_currency, :string
    field :price_usd,      :float
    field :price_inr,      :float
    field :volume,         :float

    timestamps()
  end

  @doc """
  Returns list of %Bitbns{} structs with all fields filled.
  """
  def fetch_portfolio do
    conversion_amount = Track.get_conversion_amount("USD-INR")

    product_list()
    |> Enum.map(&create_bitbns_struct/1)
    |> Enum.map(&fill_blank_price_usd(&1, conversion_amount))
    |> Enum.map(&fill_blank_price_inr(&1, conversion_amount))
  end

  defp product_list do
    %{body: body} = HTTPoison.get! url()
    Jason.decode!(body, [keys: :atoms])
    # |> Map.keys() |> Enum.sort() |> IO.inspect(limit: :infinity, width: 0)
  end

  defp url do
    "https://bitbns.com/order/getTickerWithVolume/"
  end

  defp create_bitbns_struct({key, value}) do
    case value do
      %{lowest_sell_bid: lowest_sell_bid, volume: %{volume: volume}} ->
        %Bitbns{}
        |> struct(%{product: sanitize_name(key)})
        |> struct(%{quote_currency: detect_quote_currency(key)})
        |> struct(assign_price(key, lowest_sell_bid/1))
        # For coins in INR market, volume is in Rs
        # For coins in USDT market, volume is in USDT
        |> struct(%{volume: lowest_sell_bid/1 * volume/1 |> Float.round(2)})

      %{lowest_sell_bid: lowest_sell_bid} ->
        %Bitbns{}
        |> struct(%{product: sanitize_name(key)})
        |> struct(%{quote_currency: detect_quote_currency(key)})
        |> struct(assign_price(key, lowest_sell_bid/1))
        |> struct(%{volume: 0.0})

      _ ->
        %Bitbns{}
        |> struct(%{product: sanitize_name(key)})
        |> struct(%{quote_currency: detect_quote_currency(key)})
        |> struct(%{price_inr: 0.0})
        |> struct(%{price_usd: 0.0})
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

  defp assign_price(key, price) do
    key = to_string(key)
    cond do
      String.contains?(key, "USDT") -> %{price_usd: price |> Float.round(6)}
      true                          -> %{price_inr: price |> Float.round(6)}
    end
  end

  defp fill_blank_price_usd(%Bitbns{price_inr: price_inr} = coin, conversion_amount) do
    cond do
      price_inr != nil -> struct(coin, %{price_usd: price_inr / conversion_amount |> Float.round(6)})
      true             -> coin
    end
  end

  defp fill_blank_price_inr(%Bitbns{price_usd: price_usd} = coin, conversion_amount) do
    cond do
      price_usd != nil -> struct(coin, %{price_inr: price_usd * conversion_amount |> Float.round(6)})
      true             -> coin
    end
  end
end
