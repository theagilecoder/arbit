defmodule ArbitWeb.Router do
  use ArbitWeb, :router
  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
  end

  scope "/" do
    pipe_through :browser

    pow_routes()
    get "/", ArbitWeb.PageController, :index
  end

  scope "/", ArbitWeb do
    pipe_through [:browser, :protected]

    get "/faq", PageController, :show
    get "/coinbasebitbns", CoinbasebitbnsController, :index
    get "/coinbasewazirx", CoinbasewazirxController, :index
    get "/coinbasecoindcx", CoinbasecoindcxController, :index
    get "/coinbasezebpay", CoinbasezebpayController, :index
    get "/binancebitbns", BinancebitbnsController, :index
    get "/dashboard", DashboardController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", ArbitWeb do
  #   pipe_through :api
  # end
end
