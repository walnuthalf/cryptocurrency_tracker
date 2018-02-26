defmodule CryptocurrencyTrackerWeb.TrackerChannel do
  use CryptocurrencyTrackerWeb, :channel
  alias CryptocurrencyTracker.{Currencies, Validators}

  def join("tracker:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("rates_at_time", %{"timestamp" => at_time}, socket) do
    case Validators.datetime_validator(at_time) do
      {:ok, datetime} -> 
        symbol_to_rate = Currencies.get_symbol_to_rate_at_time(at_time)
        {:reply, {:ok, symbol_to_rate}, socket}
      :error -> 
        {:reply, {:ok, %{error: "Invalid timestamp"}}, socket}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (tracker:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
