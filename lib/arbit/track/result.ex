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

  @doc """
  Given exchange1 (Source exchange) and exchange2 (Destination exchange),
  See if each product in exchange1 is present in exchange2.
  And for products that do, compute Arbitrage.
  """
  def compute_results(exchange1, exchange2) do
    conversion = Track.get_conversion_amount("USD-INR")

    get_exchange1(exchange1)
    |> Enum.map(fn x -> create_result_struct(x, exchange1, exchange2) end)
    |> Enum.reject(& &1 == nil)
    |> Enum.map(fn x -> compute_arbitrage(x, conversion) end)
  end

  # Get the product portfolio from the source exchange table
  defp get_exchange1(exchange1) do
    case exchange1 do
      "Coinbase" -> Track.list_coinbase()
      _          -> nil
    end
  end

  # For each product of exchange1, create a Result struct after trying to find it in exchange2
  defp create_result_struct(%{product: product, price_usd: price_usd}, exchange1, exchange2) do
    case get_exchange2(String.replace(product, ~r/[-].*/, "-INR"), exchange2) do
      nil -> nil
      %{product: product, price_inr: price_inr} ->
        %Result{}
        |> struct!(exchange1: exchange1)
        |> struct!(exchange2: exchange2)
        |> struct!(price1: price_usd)
        |> struct!(price2: price_inr)
        |> struct!(coin: String.replace(product, ~r/[-].*/, ""))
    end
  end

  # Get a specific product from exchange2
  defp get_exchange2(product, exchange2) do
    case exchange2 do
      "Bitbns" -> Track.get_bitbns_product(product)
      _        -> nil
    end
  end

  # Given a Result struct, put arbitrage difference % in the struct
  defp compute_arbitrage(%{price1: price1, price2: price2} = result, conversion) do
    difference = ((price2 / conversion) - price1) / price1 * 100
    struct!(result, difference: difference |> Float.round(2))
  end
end
