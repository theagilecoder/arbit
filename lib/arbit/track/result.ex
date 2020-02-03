defmodule Arbit.Track.Result do

  use Ecto.Schema
  alias Arbit.Track
  alias __MODULE__

  schema "results" do
    field :exchange1,  :string
    field :exchange2,  :string
    field :coin,       :string
    field :price1,     :float
    field :price2,     :float
    field :difference, :float

    timestamps()
  end

  def compute_results do
    conversion = Track.get_conversion_amount("USD-INR")

    Track.list_coinbase()
    |> Enum.map(fn x -> create_result_struct(x) end)
    |> Enum.reject(& &1 == nil)
    |> Enum.map(fn x -> compute_arbitrage(x, conversion) end)
  end

  defp create_result_struct(%{product: product, price_usd: price_usd}) do
    case Track.get_bitbns_product(String.replace(product, ~r/[-].*/, "-INR")) do
      nil -> nil
      %{product: product, price_inr: price_inr} ->
        %Result{}
        |> struct!(exchange1: "Coinbase")
        |> struct!(exchange2: "Bitbns")
        |> struct!(price1: price_usd)
        |> struct!(price2: price_inr)
        |> struct!(coin: String.replace(product, ~r/[-].*/, ""))
    end
  end

  defp compute_arbitrage(%{price1: price1, price2: price2} = result, conversion) do
    difference = ((price2 / conversion) - price1) / price1 * 100
    struct!(result, difference: difference |> Float.round(2))
  end
end
