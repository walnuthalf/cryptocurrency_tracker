defmodule CryptocurrencyTracker.CurrenciesTest do
  use CryptocurrencyTracker.DataCase

  alias CryptocurrencyTracker.Currencies

  describe "rate_infos" do
    alias CryptocurrencyTracker.Currencies.RateInfo

    @valid_attrs %{observed_at: "2010-04-17 14:00:00.000000Z", rate: 120.5, symbol: "some symbol"}
    @update_attrs %{observed_at: "2011-05-18 15:01:01.000000Z", rate: 456.7, symbol: "some updated symbol"}
    @invalid_attrs %{observed_at: nil, rate: nil, symbol: nil}

    def rate_info_fixture(attrs \\ %{}) do
      {:ok, rate_info} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Currencies.create_rate_info()

      rate_info
    end

    test "list_rate_infos/0 returns all rate_infos" do
      rate_info = rate_info_fixture()
      assert Currencies.list_rate_infos() == [rate_info]
    end

    test "get_rate_info!/1 returns the rate_info with given id" do
      rate_info = rate_info_fixture()
      assert Currencies.get_rate_info!(rate_info.id) == rate_info
    end

    test "create_rate_info/1 with valid data creates a rate_info" do
      assert {:ok, %RateInfo{} = rate_info} = Currencies.create_rate_info(@valid_attrs)
      assert rate_info.observed_at == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert rate_info.rate == 120.5
      assert rate_info.symbol == "some symbol"
    end

    test "create_rate_info/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Currencies.create_rate_info(@invalid_attrs)
    end

    test "update_rate_info/2 with valid data updates the rate_info" do
      rate_info = rate_info_fixture()
      assert {:ok, rate_info} = Currencies.update_rate_info(rate_info, @update_attrs)
      assert %RateInfo{} = rate_info
      assert rate_info.observed_at == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert rate_info.rate == 456.7
      assert rate_info.symbol == "some updated symbol"
    end

    test "update_rate_info/2 with invalid data returns error changeset" do
      rate_info = rate_info_fixture()
      assert {:error, %Ecto.Changeset{}} = Currencies.update_rate_info(rate_info, @invalid_attrs)
      assert rate_info == Currencies.get_rate_info!(rate_info.id)
    end

    test "delete_rate_info/1 deletes the rate_info" do
      rate_info = rate_info_fixture()
      assert {:ok, %RateInfo{}} = Currencies.delete_rate_info(rate_info)
      assert_raise Ecto.NoResultsError, fn -> Currencies.get_rate_info!(rate_info.id) end
    end

    test "change_rate_info/1 returns a rate_info changeset" do
      rate_info = rate_info_fixture()
      assert %Ecto.Changeset{} = Currencies.change_rate_info(rate_info)
    end
  end
end
