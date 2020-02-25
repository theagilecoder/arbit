defmodule ArbitWeb.CoinbasebitbnsController do
  use ArbitWeb, :controller

  def index(conn, _params) do
    results = nil
    render(conn, "index.html", results: results)
  end
end
