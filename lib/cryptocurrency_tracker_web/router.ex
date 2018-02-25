defmodule CryptocurrencyTrackerWeb.Router do
  use CryptocurrencyTrackerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CryptocurrencyTrackerWeb do
    pipe_through :api
  end
end
