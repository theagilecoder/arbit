defmodule Arbit.Track.Wazirx do
  use Ecto.Schema
  alias __MODULE__

  schema "wazirx" do
    field :product, :string
    field :price_usd, :float
    field :price_inr, :float

    timestamps()
  end

  @doc """
    Returns API URL of Wazirx
  """
  def url do
    "https://api.wazirx.com/api/v2/tickers"
  end

  @doc """
    Returns Wazirx's list of products
  """
  def product_list do
    %{body: body} = HTTPoison.get! url()
    Jason.decode!(body, [keys: :atoms])
    # |> Map.keys() |> Enum.sort() |> IO.inspect(limit: :infinity, width: 0)
  end

  @doc """
    For each product in the list, create a struct
    and return a list of such structs
  """
  def fetch_portfolio do
    product_list()
    |> Enum.map(&create_wazirx_struct/1)
  end

  # Given a map, Create struct
  defp create_wazirx_struct({key, %{buy: price_inr}}) do
    %Wazirx{}
    |> struct(%{product: sanitize_name(key)})
    |> struct(%{price_inr: String.to_float(price_inr)})
  end

  # Receives :btcinr, returns "BTC-INR"
  defp sanitize_name(product) do
    product = product |> to_string() |> String.upcase()

    cond do
      String.ends_with?(product, "INR")  -> String.replace_suffix(product, "INR", "-INR")
      String.ends_with?(product, "BTC")  -> String.replace_suffix(product, "BTC", "-BTC")
      String.ends_with?(product, "USDT") -> String.replace_suffix(product, "USDT", "-USDT")
      true                               -> "NULL"
    end
  end
end
