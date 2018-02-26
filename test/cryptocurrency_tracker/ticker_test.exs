defmodule CryptocurrencyTracker.TickerTest do
  use ExUnit.Case 
  require CryptocurrencyTracker.TestDispatcher
  alias CryptocurrencyTracker.Ticker
  alias CryptocurrencyTracker.TestDispatcher

  @grace_period 7000
  setup do 
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CryptocurrencyTracker.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(CryptocurrencyTracker.Repo, {:shared, self()})
    {:ok, dispatcher} = GenServer.start_link(TestDispatcher, [name: TestDispatcher]) 
    {:ok, ticker} = GenServer.start_link(Ticker, dispatcher, [name: TestTicker])
    {:ok, dispatcher: dispatcher, ticker: ticker}
  end

  test "ticker sends new_rate_datas", %{dispatcher: dispatcher} do
    :timer.sleep @grace_period
    dispatcher_state = GenServer.call(dispatcher, :state)  
    %{rate_datas: rate_datas, observed_at: _observed_at} = dispatcher_state
    symbol_to_rate = Map.new(rate_datas) 
    symbols = MapSet.new(Map.keys(symbol_to_rate))
    expected_symbols = MapSet.new(["BTC", "ETH", "BCH"])
    assert symbols == expected_symbols
  end
end
