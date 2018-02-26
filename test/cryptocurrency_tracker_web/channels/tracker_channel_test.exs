defmodule CryptocurrencyTrackerWeb.TrackerChannelTest do
  use CryptocurrencyTrackerWeb.ChannelCase
  require ExUnitProperties 

  alias CryptocurrencyTrackerWeb.TrackerChannel
  alias CryptocurrencyTracker.Currencies

  setup do
    # seed the DB
    symbols = ["BTC", "ETH", "BCH"]
    now_unix = DateTime.utc_now() |> DateTime.to_unix
    datetimes = Range.new(1, 100) 
                |> Enum.map(fn i -> 
                  (now_unix - i*300) |> DateTime.from_unix! |> DateTime.to_iso8601 
    end)
    params_generator = fn symbol ->  
      ExUnitProperties.gen all rate <- StreamData.float(min: 0.0),
      datetime <- StreamData.member_of(datetimes) do 
        %{symbol: symbol, 
          rate: rate, 
          observed_at: datetime}
      end
    end
    Enum.each(symbols, fn symbol ->
      params_combos = Enum.take(StreamData.resize(params_generator.(symbol), 100), 100)
      Enum.each(params_combos, fn params -> 
        Currencies.create_rate_info(params)
      end)
    end)

    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(TrackerChannel, "tracker:lobby")
    {:ok, socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "shout broadcasts to tracker:lobby", %{socket: socket} do
    push socket, "shout", %{"hello" => "all"}
    assert_broadcast "shout", %{"hello" => "all"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end

  test "rates_at_time replies with symbol_to_rate", %{socket: socket} do
    timestamp_str = DateTime.utc_now() |> DateTime.to_iso8601
    ref = push socket, "rates_at_time", %{"timestamp" => timestamp_str}
    assert_reply ref, :ok, %{"BTC" => _btc_rate, "ETH" => _eth_rate, "BCH"=> _bch_rate}
  end

  test "rates_at_time replies with an error message for invalid input", %{socket: socket} do
    bad_timestamp_str = "Not a date"
    ref = push socket, "rates_at_time", %{"timestamp" => bad_timestamp_str}
    assert_reply(ref, :ok, %{error: _error_msg})
  end
end
