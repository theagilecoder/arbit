defmodule Arbit.Track.Binance do
  @moduledoc """
  This module calls Binance tracker API and prepares list of %Binance{} structs
  Currently tracking USDT, USDC and BTC pairs
  """

  use Ecto.Schema
  alias Arbit.Track
  alias __MODULE__

  schema "binance" do
    field :coin,           :string
    field :quote_currency, :string
    field :price_usd,      :float
    field :price_inr,      :float
    field :price_btc,      :float

    timestamps()
  end

  @doc """
    Returns list of %Binance{} structs with all fields filled
  """
  def fetch_portfolio do
    conversion_amount = Track.get_conversion_amount("USD-INR")

    product_list()
    |> filter_relevant_pairs()
    |> Enum.map(&create_binance_struct/1)
    |> Enum.map(&fill_blank_price_inr(&1, conversion_amount))
  end

  defp product_list do
    %{body: body} = HTTPoison.get! url()
    Jason.decode!(body, [keys: :atoms])
  end

  defp url do
    "https://api.binance.com/api/v3/ticker/price"
  end

  defp filter_relevant_pairs(coin_list) do
    # btc_pairs_list = Enum.filter(coin_list, & String.ends_with?(&1.symbol, "BTC"))

    # Coins with USDC pairing present in UI
    usdc_ui_pairs_list = [
      "ADAUSDC", "ATOMUSDC", "BATUSDC", "BCHUSDC", "BGBPUSDC", "BNBUSDC", "BTCUSDC",
      "BTTUSDC", "EOSUSDC", "ETHUSDC", "LINKUSDC", "LTCUSDC", "NEOUSDC", "ONEUSDC",
      "TOMOUSDC", "TRXUSDC", "WAVESUSDC", "WINUSDC", "XRPUSDC", "ZECUSDC"
    ]

    # Include coins only that are present in UI
    usdc_pairs_list = Enum.filter(coin_list, & &1.symbol in usdc_ui_pairs_list)

    # Coins with USDT pairing present in UI
    usdt_ui_pairs_list = [
      "ADAUSDT", "AIONUSDT", "ALGOUSDT", "ANKRUSDT", "ARPAUSDT", "ATOMUSDT", "BANDUSDT",
      "BATUSDT", "BCHUSDT", "BEAMUSDT", "BNBUSDT", "BNTUSDT", "BTCUSDT", "BTSUSDT", "BTTUSDT",
      "BUSDUSDT", "CELRUSDT", "CHZUSDT", "COCOSUSDT", "COSUSDT", "COTIUSDT", "CTXCUSDT",
      "CVCUSDT", "DASHUSDT", "DENTUSDT", "DOCKUSDT", "DOGEUSDT", "DREPUSDT", "DUSKUSDT",
      "ENJUSDT", "EOSUSDT", "ERDUSDT", "ETCUSDT", "ETHUSDT", "EURUSDT", "FETUSDT", "FTMUSDT",
      "FTTUSDT", "FUNUSDT", "GTOUSDT", "HBARUSDT", "HCUSDT", "HOTUSDT", "ICXUSDT", "IOSTUSDT",
      "IOTAUSDT", "IOTXUSDT", "KAVAUSDT", "KEYUSDT", "LINKUSDT", "LSKUSDT", "LTCUSDT",
      "LTOUSDT", "MATICUSDT", "MBLUSDT", "MCOUSDT", "MFTUSDT", "MITHUSDT", "MTLUSDT",
      "NANOUSDT", "NEOUSDT", "NKNUSDT", "NPXSUSDT", "NULSUSDT", "OGNUSDT", "OMGUSDT",
      "ONEUSDT", "ONGUSDT", "ONTUSDT", "PAXUSDT", "PERLUSDT", "QTUMUSDT", "RENUSDT", "RLCUSDT",
      "RVNUSDT", "STORMUSDT", "STPTUSDT", "STRATUSDT", "STXUSDT", "TCTUSDT", "TFUELUSDT",
      "THETAUSDT", "TOMOUSDT", "TROYUSDT", "TRXUSDT", "TUSDUSDT", "USDCUSDT", "USDSUSDT",
      "VETUSDT", "VITEUSDT", "WANUSDT", "WAVESUSDT", "WINUSDT", "WRXUSDT", "XLMUSDT",
      "XMRUSDT", "XRPUSDT", "XTZUSDT", "ZECUSDT", "ZILUSDT", "ZRXUSDT"
    ]

    # Include coins only that are present in UI
    usdt_pairs_list = Enum.filter(coin_list, & &1.symbol in usdt_ui_pairs_list)

    # Return all relevant coin pairs
    usdc_pairs_list ++ usdt_pairs_list
  end

  # Convert a coin map to a %Binance{} struct
  defp create_binance_struct(coin_map) do
    quote_currency = detect_quote_currency(coin_map.symbol)

    %Binance{}
    |> struct!(%{coin: sanitize_name(coin_map.symbol)})
    |> struct!(%{quote_currency: quote_currency})
    |> struct!(%{price_btc: (if quote_currency == "BTC",  do: coin_map.price |> Float.parse() |> elem(0), else: nil)})
    |> struct!(%{price_usd: (if quote_currency in ["USDT", "USDC"], do: coin_map.price |> Float.parse() |> elem(0), else: nil)})
  end

  defp sanitize_name(symbol) do
    cond do
      String.ends_with?(symbol, "BTC")  -> String.replace_trailing(symbol, "BTC",  "")
      String.ends_with?(symbol, "USDT") -> String.replace_trailing(symbol, "USDT", "")
      String.ends_with?(symbol, "USDC") -> String.replace_trailing(symbol, "USDC", "")
      true                              -> symbol
    end
  end

  defp detect_quote_currency(symbol) do
    cond do
      String.ends_with?(symbol, "BTC")  -> "BTC"
      String.ends_with?(symbol, "USDT") -> "USDT"
      String.ends_with?(symbol, "USDC") -> "USDC"
      true                              -> symbol
    end
  end

  defp fill_blank_price_inr(%Binance{price_usd: price_usd} = coin, conversion_amount) do
    cond do
      price_usd != nil -> struct(coin, %{price_inr: price_usd * conversion_amount})
      true             -> coin
    end
  end
end
