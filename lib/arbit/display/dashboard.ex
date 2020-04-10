defmodule Arbit.Display.Dashboard do
   @moduledoc """
    This module is responsible for getting and collating all arbitrage results
  """

  use Ecto.Schema
  alias Arbit.Display
  alias __MODULE__

  schema "dashboard" do
    field :coin,           :string
    field :ex1,            :string
    field :ex1_quote,      :string
    field :ex1_price,      :float
    field :ex2,            :string
    field :ex2_quote,      :string
    field :ex2_bid_price,  :float
    field :ex2_ask_price,  :float
    field :bid_difference, :float
    field :ask_difference, :float
    field :ex2_volume,     :float

    timestamps()
  end

  @doc """
  Collect all results structs into a list
  """
  def collect_all_results() do
    (Display.list_coinbasebitbns() |> Enum.map(&create_dashboard_struct(&1, "coinbase", "bitbns")))
      ++ (Display.list_coinbasewazirx()  |> Enum.map(&create_dashboard_struct(&1, "coinbase", "wazirx")))
      ++ (Display.list_coinbasecoindcx() |> Enum.map(&create_dashboard_struct(&1, "coinbase", "coindcx")))
      ++ (Display.list_coinbasezebpay()  |> Enum.map(&create_dashboard_struct(&1, "coinbase", "zebpay")))
      ++ (Display.list_binancebitbns()   |> Enum.map(&create_dashboard_struct(&1, "binance", "bitbns")))
  end

  # Given one result struct, create %Dashboard struct
  def create_dashboard_struct(result, ex1, ex2) do
    %Dashboard{}
    |> struct(%{coin:           result.coin})
    |> struct(%{ex1:            String.capitalize(ex1)})
    |> struct(%{ex1_quote:      Map.get(result, String.to_atom(ex1<>"_quote"))})
    |> struct(%{ex1_price:      Map.get(result, String.to_atom(ex1<>"_price"))})
    |> struct(%{ex2:            String.capitalize(ex2)})
    |> struct(%{ex2_quote:      Map.get(result, String.to_atom(ex2<>"_quote"))})
    |> struct(%{ex2_bid_price:  Map.get(result, String.to_atom(ex2<>"_bid_price"))})
    |> struct(%{ex2_ask_price:  Map.get(result, String.to_atom(ex2<>"_ask_price"))})
    |> struct(%{bid_difference: result.bid_difference})
    |> struct(%{ask_difference: result.ask_difference})
    |> struct(%{ex2_volume:     Map.get(result, String.to_atom(ex2<>"_volume"))})
  end
end
