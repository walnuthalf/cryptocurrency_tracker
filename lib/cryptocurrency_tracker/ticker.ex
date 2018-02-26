defmodule CryptocurrencyTracker.Ticker do
  use GenServer
  alias CryptocurrencyTracker.Dispatcher

  @refresh_period 2000
  @price_endpoint "https://min-api.cryptocompare.com/data/price?"
  @crypto_symbols ["BTC", "ETH", "BCH"]

  def init(dispatcher) do
    update_rates()
    state = %{symbol_to_rate: %{},
      dispatcher: dispatcher
    }
    {:ok, state}
  end

  def start_link(name, dispatcher) do
    GenServer.start_link(__MODULE__, dispatcher, [name: name])
  end

  # GenServer callbacks
  def handle_call(:ping, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:update_rates, state) do
    # helper for polling
    update_rates()
    # map crypto_symbols to latest rates
    rate_datas = Enum.map(@crypto_symbols, &fetch_rate/1)
    new_symbol_to_rate = Map.new(rate_datas)
    new_state = Map.put(state, :symbol_to_rate, new_symbol_to_rate)
    dispatcher = Map.get(state, :dispatcher)
    GenServer.call(dispatcher, {:new_rate_datas, rate_datas})
    {:noreply, new_state}
  end
  
  # helper func for polling rates
  defp update_rates do
    Process.send_after(self(), :update_rates, @refresh_period) 
  end

  defp fetch_rate(crypto_symbol) do
    req_params = [fsym: crypto_symbol, tsyms: "USD"] 
    param_str = Plug.Conn.Query.encode(req_params)
    url = @price_endpoint <> param_str
    # pattern match the response, deal with errors
    # returns {crypto_symbol, info}
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Poison.decode(body) do
          {:ok, %{"USD" => rate}} ->
            {crypto_symbol, {:ok, rate}}
          _ -> 
            {crypto_symbol, :unexpected_body}
        end
      _ ->
        {crypto_symbol, :response_error}
    end
  end
end
