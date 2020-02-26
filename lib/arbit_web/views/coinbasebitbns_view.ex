defmodule ArbitWeb.CoinbasebitbnsView do
  use ArbitWeb, :view

  @doc """
  Filters INR quoted coins from all results and sorts in descending order of difference
  """
  def filter_inr_quotes(results) do
    results
    |> Enum.filter(fn %{quote_currency: quote_currency} -> quote_currency == "INR" end)
    |> Enum.sort_by(fn x -> x.difference end, &>=/2)
  end

  @doc """
  Filters USDT quoted coins from all results and sorts in descending order of difference
  """
  def filter_usdt_quotes(results) do
    results
    |> Enum.filter(fn %{quote_currency: quote_currency} -> quote_currency == "USDT" end)
    |> Enum.sort_by(fn x -> x.difference end, &>=/2)
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

  def format_percentage(number) do
    Number.Percentage.number_to_percentage(number, precision: 2 )
  end
end
