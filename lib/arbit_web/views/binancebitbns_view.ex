defmodule ArbitWeb.BinancebitbnsView do
  use ArbitWeb, :view

  @doc """
  Filters USDC - INR quoted coins from all results and sorts in descending order of bid_difference
  """
  def filter_usdc_inr_and_sort_by_bid_difference(results) do
    results
    |> Enum.filter(fn %{binance_quote_currency: binance_quote_currency} -> binance_quote_currency == "USDC" end)
    |> Enum.filter(fn %{bitbns_quote_currency: bitbns_quote_currency} -> bitbns_quote_currency == "INR" end)
    |> Enum.sort_by(fn x -> x.bid_difference end, &>=/2)
  end

  @doc """
  Filters USDC - INR quoted coins from all results and sorts in descending order of ask_difference
  """
  def filter_usdc_inr_and_sort_by_ask_difference(results) do
    results
    |> Enum.filter(fn %{binance_quote_currency: binance_quote_currency} -> binance_quote_currency == "USDC" end)
    |> Enum.filter(fn %{bitbns_quote_currency: bitbns_quote_currency} -> bitbns_quote_currency == "INR" end)
    |> Enum.sort_by(fn x -> x.ask_difference end, &>=/2)
  end

  @doc """
  Filters USDT - INR quoted coins from all results and sorts in descending order of bid_difference
  """
  def filter_usdt_inr_and_sort_by_bid_difference(results) do
    results
    |> Enum.filter(fn %{binance_quote_currency: binance_quote_currency} -> binance_quote_currency == "USDT" end)
    |> Enum.filter(fn %{bitbns_quote_currency: bitbns_quote_currency} -> bitbns_quote_currency == "INR" end)
    |> Enum.sort_by(fn x -> x.bid_difference end, &>=/2)
  end

  @doc """
  Filters USDT - INR quoted coins from all results and sorts in descending order of ask_difference
  """
  def filter_usdt_inr_and_sort_by_ask_difference(results) do
    results
    |> Enum.filter(fn %{binance_quote_currency: binance_quote_currency} -> binance_quote_currency == "USDT" end)
    |> Enum.filter(fn %{bitbns_quote_currency: bitbns_quote_currency} -> bitbns_quote_currency == "INR" end)
    |> Enum.sort_by(fn x -> x.ask_difference end, &>=/2)
  end

  @doc """
  Picks last updated time from list of structs
  """
  def ist_time(results) do
    result = List.first(results)
    utc_time = result.updated_at
    ist_time = NaiveDateTime.add(utc_time, 19800)
    %{ist_time | second: 0}
  end

  def format_rupee(number) do
    Number.Currency.number_to_currency(number, unit: "₹ ")
  end

  def format_dollar(number) do
    Number.Currency.number_to_currency(number, unit: "$ ")
  end

  def format_coin_units(number) do
    Number.Currency.number_to_currency(number, unit: "c.", format: "%n %u")
  end

  def format_percentage(number) do
    Number.Percentage.number_to_percentage(number, precision: 2 )
  end
end
