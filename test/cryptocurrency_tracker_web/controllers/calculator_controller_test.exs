defmodule CryptocurrencyTrackerWeb.CalculatorControllerTest do
  use CryptocurrencyTrackerWeb.ConnCase, async: true
  require ExUnitProperties

  test "#calculate with valid params", %{conn: conn} do
    symbols = ["BTC", "ETH", "BCH"]
    now_unix = DateTime.utc_now() |> DateTime.to_unix
    datetimes = Range.new(1, 12) 
                |> Enum.map(fn i -> 
                  (now_unix - i*300) |> DateTime.from_unix! |> DateTime.to_iso8601 
    end)
    
    params_generator = 
      ExUnitProperties.gen all amount <- StreamData.float(min: 0.0),
      symbol <- StreamData.member_of(symbols),
      datetime <- StreamData.member_of(datetimes) do 
        three_params = [symbol: symbol, 
                  amount: Float.to_string(amount), 
                  datetime: datetime]
        two_params = [symbol: symbol, 
                  amount: Float.to_string(amount)]
        {three_params, two_params}
      end

    params_combos = Enum.take(StreamData.resize(params_generator, 100), 100)
    Enum.each(params_combos, fn {three_params, two_params} ->
      three_params_str = Plug.Conn.Query.encode(three_params)
      two_params_str = Plug.Conn.Query.encode(two_params)

      %{resp_body: body, status: status} = get(conn, "/api/calculator?" <> three_params_str)
      %{"sum" => sum} = Poison.decode!(body)
      assert is_number(sum)
      assert 200 == status

      %{resp_body: body, status: status} = get(conn, "/api/calculator?" <> two_params_str)
      %{"sum" => sum} = Poison.decode!(body)
      assert is_number(sum)
      assert 200 == status
    end)
  end

  test "#calculate with invalid params", %{conn: conn} do
    symbols = ["BT", "ET", "BC", "BTCC", "111"]
    datetimes = ["hello", "not valid datetime", "bad"]    
    amounts = ["one", "two", "three", "xyy"]
    params_generator = 
      ExUnitProperties.gen all amount <- StreamData.member_of(amounts),
      symbol <- StreamData.member_of(symbols),
      datetime <- StreamData.member_of(datetimes) do 
        three_params = [symbol: symbol, 
                  amount: amount, 
                  datetime: datetime]
        two_params = [symbol: symbol, 
                  amount: amount]
        {three_params, two_params}
      end

    params_combos = Enum.take(StreamData.resize(params_generator, 100), 100)
    Enum.each(params_combos, fn {three_params, two_params} ->
      three_params_str = Plug.Conn.Query.encode(three_params)
      two_params_str = Plug.Conn.Query.encode(two_params)

      %{resp_body: body, status: status} = get(conn, "/api/calculator?" <> three_params_str)
      assert %{"error" => "Invalid parameters"} = Poison.decode!(body)
      assert 200 == status

      %{resp_body: body, status: status} = get(conn, "/api/calculator?" <> two_params_str)
      assert %{"error" => "Invalid parameters"} = Poison.decode!(body)
      assert 200 == status
    end)
  end

  test "#calculate with missing params", %{conn: conn} do
    symbols = ["BTC", "ETH", "BCH"]
    now_unix = DateTime.utc_now() |> DateTime.to_unix
    datetimes = Range.new(1, 12) 
                |> Enum.map(fn i -> 
                  (now_unix - i*300) |> DateTime.from_unix! |> DateTime.to_iso8601 
    end)
    
    params_generator = 
      ExUnitProperties.gen all amount <- StreamData.float(min: 0.0),
      symbol <- StreamData.member_of(symbols),
      datetime <- StreamData.member_of(datetimes) do 
        {symbol, amount, datetime}
      end

    params_combos = Enum.take(StreamData.resize(params_generator, 100), 100)
    Enum.each(params_combos, fn {symbol, amount, datetime} ->
      missing_permutations = [[amount: amount],
                              [amount: amount, datetime: datetime],
                              [symbol: symbol],
                              [symbol: symbol, datetime: datetime], 
                              [] ]
      Enum.each(missing_permutations, fn perm ->
        params_str = Plug.Conn.Query.encode(perm)
        %{resp_body: body, status: status} = get(conn, "/api/calculator?" <> params_str)
        assert %{"error" => "Missing parameters"} = Poison.decode!(body)
        assert 200 == status
      end)
    end)
  end
end
