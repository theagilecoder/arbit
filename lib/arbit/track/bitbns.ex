defmodule Arbit.Track.Bitbns do
  use Ecto.Schema
  alias __MODULE__

  schema "bitbns" do
    field :product, :string
    field :price_usd, :float
    field :price_inr, :float

    timestamps()
  end

  @doc """
    Returns API URL of a given product
  """
  def url do
    "https://bitbns.com/order/getTickerWithVolume/"
  end

  @doc """
    Returns Bitbns's list of products
  """
  def product_list do
    %{body: body} = HTTPoison.get! url()
    Jason.decode!(body, [keys: :atoms])
    # |> Map.keys() |> Enum.sort() |> IO.inspect(limit: :infinity, width: 0)
  end

  def fetch_portfolio do
    product_list()
    |> Enum.map(&create_bitbns_struct/1)
  end

  defp create_bitbns_struct({key, %{lowest_sell_bid: lowest_sell_bid}}) do
    %Bitbns{}
    |> struct(%{product: to_string(key)<>"-INR"})
    |> struct(%{price_inr: lowest_sell_bid/1 |> Float.round(2)})
  end
end
