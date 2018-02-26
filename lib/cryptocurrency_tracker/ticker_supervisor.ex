defmodule CryptocurrencyTracker.TickerSupervisor do
  use Supervisor
  alias CryptocurrencyTracker.Ticker
  alias CryptocurrencyTracker.Dispatcher

  def init(_arg) do
    children = [worker(Dispatcher, [Dispatcher]),
                worker(Ticker, [Ticker, Dispatcher])]
    supervise(children, strategy: :one_for_one)
  end

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end
end
