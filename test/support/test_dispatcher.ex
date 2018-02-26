defmodule CryptocurrencyTracker.TestDispatcher do
  use GenServer

  def init(_arg) do
    state = %{}
    {:ok, state}
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], [name: name])
  end

  # GenServer callbacks
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:new_rate_datas, rate_datas}, _from, state) do
    time_now = DateTime.utc_now()
    new_state = %{rate_datas: rate_datas,
      observed_at: time_now}
    {:reply, state, new_state}
  end
end
