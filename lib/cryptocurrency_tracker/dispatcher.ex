defmodule CryptocurrencyTracker.Dispatcher do
  use GenServer
  alias CryptocurrencyTracker.Currencies.RateInfo
  alias CryptocurrencyTrackerWeb.Endpoint
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
    save_new_rates(rate_datas)
    broadcast_new_rates(rate_datas)
    {:reply, state, state}
  end

  defp broadcast_new_rates(rate_datas) do
    symbol_to_rate = Enum.map(rate_datas, fn {symbol, {:ok, rate}} ->
      {symbol, rate}
    end) |> Map.new 
    Endpoint.broadcast("tracker:lobby", "new_rates", symbol_to_rate)
  end

  defp save_new_rates(rate_datas) do
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
  end
end
