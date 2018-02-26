defmodule CryptocurrencyTrackerWeb.CalculatorView do
  use CryptocurrencyTrackerWeb, :view

  def render("calculator.json", %{sum: sum}) do
    %{
      sum: sum
    }
  end
end
