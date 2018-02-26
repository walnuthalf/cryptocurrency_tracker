defmodule CryptocurrencyTracker.DispatcherTest do
  alias CryptocurrencyTracker.{Repo, Dispatcher}
  alias CryptocurrencyTracker.Currencies.RateInfo
  alias CryptocurrencyTrackerWeb.TrackerChannel
  use CryptocurrencyTrackerWeb.ChannelCase

  setup do 
    # :ok = Ecto.Adapters.SQL.Sandbox.checkout(CryptocurrencyTracker.Repo)
    # Ecto.Adapters.SQL.Sandbox.mode(CryptocurrencyTracker.Repo, {:shared, self()})
    {:ok, dispatcher} = GenServer.start_link(Dispatcher, [name: DBChannelTestDispatcher]) 
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(TrackerChannel, "tracker:lobby")
    {:ok, socket: socket, dispatcher: dispatcher}
  end

  def convert_rate_infos(rate_infos) do
    rate_infos |> Enum.map(fn rate_info -> 
      {rate_info.symbol, rate_info.rate}
    end) |> Map.new 
  end

  test "dispatcher saves to DB and broadcasts", %{dispatcher: dispatcher} do
    rate_datas = [{"BTC", {:ok, 1111.1}}, 
                  {"ETH", {:ok, 22.2}}, 
                  {"BCH", {:ok, 333.21}}] 
    symbol_to_rate = Enum.map(rate_datas, fn {symbol, {:ok, rate}} ->
      {symbol, rate}
    end) |> Map.new 
    GenServer.call(dispatcher, {:new_rate_datas, rate_datas})  
    db_symbol_to_rate = Repo.all(RateInfo) |> convert_rate_infos
    assert Map.equal?(symbol_to_rate, db_symbol_to_rate)
    assert_broadcast "new_rates", broadcasted_symbol_to_rate 
    assert Map.equal?(symbol_to_rate, broadcasted_symbol_to_rate)
  end
end
