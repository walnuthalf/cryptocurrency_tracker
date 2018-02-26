defmodule CryptocurrencyTrackerWeb.CalculatorController do
  use CryptocurrencyTrackerWeb, :controller
  alias CryptocurrencyTracker.{Validators, Currencies}
  alias CryptocurrencyTrackerWeb.ErrorView

  def calculate(conn, raw_params) do
    allowed_params = ["amount", "at_time", "symbol"]
    params = Map.take(raw_params, allowed_params)
    param_to_validator = %{
      "amount" => &Validators.float_validator/1,
      "at_time" => &Validators.datetime_validator/1,
      "symbol" => &Validators.symbol_validator/1
    }
    parsed_params = Validators.params_validator(params, param_to_validator)
    case parsed_params do
      {:error, errors} -> 
        render(conn, ErrorView, "invalid_parameters.json", %{details: errors})
      {:ok, %{"amount" => amount, "at_time" => at_time, "symbol" => symbol}} -> 
        rate = closest_rate(symbol, at_time)
        render(conn, "calculator.json", sum: rate*amount)
      {:ok, %{"amount" => amount, "symbol" => symbol}} -> 
        at_time = DateTime.utc_now()
        rate = closest_rate(symbol, at_time)
        render(conn, "calculator.json", sum: rate*amount)
      _ -> 
        render(conn, ErrorView, "missing_parameters.json", %{params: ["amount", "symbol"]})
    end
  end
  
  defp closest_rate(symbol, at_time) do
    case Currencies.get_rate_info_at_time(symbol, at_time) do
      {:ok, rate_info} -> rate_info.rate
      _ -> 0.0
    end
  end
end
