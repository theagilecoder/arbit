defmodule Arbit.Track.Wazirx do
  @moduledoc """
  This module calls Wazirx API and prepares list of %Wazirx{} structs
  in 3 quote currencies - INR, USDT and BTC
  Volume is in whatever the quote unit is
  """

  use Ecto.Schema
  alias Arbit.Track
  alias __MODULE__

  schema "wazirx" do
    field :coin,           :string
    field :quote_currency, :string
    field :price_usd,      :float
    field :price_inr,      :float
    field :price_btc,      :float
    field :volume,         :float

    timestamps()
  end

  @doc """
    Returns list of %Wazirx{} structs with all fields filled
  """
  def fetch_portfolio do
    conversion_amount = Track.get_conversion_amount("USD-INR")

    product_list()
    |> Enum.map(&create_wazirx_struct/1)
    |> Enum.map(&fill_blank_price_inr(&1, conversion_amount))
    |> Enum.map(&fill_blank_price_usd(&1, conversion_amount))
  end

  # Parses API response
  defp product_list do
    %{body: body} = HTTPoison.get! url()
    Jason.decode!(body, [keys: :atoms])
    # |> Map.keys() |> Enum.sort() |> IO.inspect(limit: :infinity, width: 0)
  end

  defp url do
    "https://api.wazirx.com/api/v2/tickers"
  end

  # Given a map, Create a %Wazirx{} struct
  defp create_wazirx_struct({_key, value}) do
    %Wazirx{}
    |> struct(%{coin:           value.base_unit |> String.upcase()})
    |> struct(%{quote_currency: value.quote_unit |> String.upcase()})
    |> struct(%{volume:         value.volume |> Float.parse() |> elem(0)})
    |> struct(%{price_inr: (if value.quote_unit == "inr",  do: value.buy |> Float.parse() |> elem(0), else: nil)})
    |> struct(%{price_btc: (if value.quote_unit == "btc",  do: value.buy |> Float.parse() |> elem(0), else: nil)})
    |> struct(%{price_usd: (if value.quote_unit == "usdt", do: value.buy |> Float.parse() |> elem(0), else: nil)})
  end

  defp fill_blank_price_inr(%Wazirx{price_usd: price_usd} = coin, conversion_amount) do
    cond do
      price_usd != nil -> struct(coin, %{price_inr: price_usd * conversion_amount})
      true             -> coin
    end
  end

  defp fill_blank_price_usd(%Wazirx{price_inr: price_inr} = coin, conversion_amount) do
    cond do
      price_inr != nil -> struct(coin, %{price_usd: price_inr / conversion_amount})
      true             -> coin
    end
  end
end
