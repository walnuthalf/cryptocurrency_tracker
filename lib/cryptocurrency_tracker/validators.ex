defmodule CryptocurrencyTracker.Validators do
  def params_validator(params, param_to_validator) do
    validated_params = Enum.map(Map.keys(params), fn param ->
      param_str_value = Map.get(params, param)
      {param, Map.get(param_to_validator, param).(param_str_value)}  
    end)
    parsed_params = Enum.flat_map(validated_params, fn v_param ->
      case v_param do
        {param, {:ok, parsed_value}} -> [{param, parsed_value}]
        _ -> []
      end
    end)
    errors = Enum.flat_map(validated_params, fn v_param ->
      case v_param do
        {param, :error} -> ["invalid #{param}"]
        _ -> [] 
      end
    end)
    if Enum.empty?(errors) do
      {:ok, Map.new(parsed_params)}
    else
      {:error, errors}
    end
  end

  def datetime_validator(datetime_str) do
    if is_bitstring(datetime_str) do
      case DateTime.from_iso8601(datetime_str) do 
        {:ok,datetime, _} -> {:ok, datetime} 
        _ -> :error
      end
    else
      :error
    end
  end

  def float_validator(num_str) do
    case Float.parse(num_str) do
      {num, _} -> {:ok, num}
      :error -> :error
    end
  end

  def symbol_validator(symbol) do
    allowed_symbols = MapSet.new(["BTC", "ETH", "BCH"])
    if MapSet.member?(allowed_symbols, symbol) do
      {:ok, symbol}
    else
      :error
    end
  end
end
