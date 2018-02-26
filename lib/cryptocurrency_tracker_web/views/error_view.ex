defmodule CryptocurrencyTrackerWeb.ErrorView do
  use CryptocurrencyTrackerWeb, :view

  def render("invalid_parameters.json", %{details: errors}) do
    %{error: "Invalid parameters", 
      details: errors
    }
  end

  def render("missing_parameters.json", %{params: params}) do
    %{error: "Missing parameters", 
      "expected_parameters": params}
  end

  def render("404.json", _assigns) do
    %{errors: %{detail: "Page not found"}}
  end

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json", assigns
  end
end
