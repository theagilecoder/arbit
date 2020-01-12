defmodule Arbit.TrackTest do
  use Arbit.DataCase

  alias Arbit.Track

  describe "currencies" do
    alias Arbit.Track.Currency

    @valid_attrs %{amount: 120.5, pair: "some pair"}
    @update_attrs %{amount: 456.7, pair: "some updated pair"}
    @invalid_attrs %{amount: nil, pair: nil}

    def currency_fixture(attrs \\ %{}) do
      {:ok, currency} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Track.create_currency()

      currency
    end

    test "list_currencies/0 returns all currencies" do
      currency = currency_fixture()
      assert Track.list_currencies() == [currency]
    end

    test "get_currency!/1 returns the currency with given id" do
      currency = currency_fixture()
      assert Track.get_currency!(currency.id) == currency
    end

    test "create_currency/1 with valid data creates a currency" do
      assert {:ok, %Currency{} = currency} = Track.create_currency(@valid_attrs)
      assert currency.amount == 120.5
      assert currency.pair == "some pair"
    end

    test "create_currency/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Track.create_currency(@invalid_attrs)
    end

    test "update_currency/2 with valid data updates the currency" do
      currency = currency_fixture()
      assert {:ok, %Currency{} = currency} = Track.update_currency(currency, @update_attrs)
      assert currency.amount == 456.7
      assert currency.pair == "some updated pair"
    end

    test "update_currency/2 with invalid data returns error changeset" do
      currency = currency_fixture()
      assert {:error, %Ecto.Changeset{}} = Track.update_currency(currency, @invalid_attrs)
      assert currency == Track.get_currency!(currency.id)
    end

    test "delete_currency/1 deletes the currency" do
      currency = currency_fixture()
      assert {:ok, %Currency{}} = Track.delete_currency(currency)
      assert_raise Ecto.NoResultsError, fn -> Track.get_currency!(currency.id) end
    end

    test "change_currency/1 returns a currency changeset" do
      currency = currency_fixture()
      assert %Ecto.Changeset{} = Track.change_currency(currency)
    end
  end
end
