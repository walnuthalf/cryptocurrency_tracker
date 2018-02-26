defmodule CryptocurrencyTracker.Dispatcher do
  use GenServer
  alias CryptocurrencyTracker.Currencies.RateInfo
  require Logger

  def init(_arg) do
    state = %{}
    {:ok, state}
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], [name: name])
  end

  # GenServer callbacks
  def handle_call(:ping, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:new_rate_datas, rate_datas}, _from, state) do
    Enum.each(rate_datas, fn rate_data ->
      case rate_data do
        {symbol, {:ok, rate}} -> 
          params = %{symbol: symbol,
            rate: rate, 
            observed_at: DateTime.utc_now()
          }
          changeset = RateInfo.changeset(%RateInfo{}, params)
          CryptocurrencyTracker.Repo.insert(changeset)
        {symbol, error} -> 
          log_str = "problem fetching rate for #{symbol}, error: #{error}"
          Logger.warn(log_str) 
      end
    end)
    {:reply, state, state}
  end
end
