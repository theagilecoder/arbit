defmodule ArbitWeb.CoinbasecoindcxController do
  use ArbitWeb, :controller
  alias Arbit.Display

  def index(conn, _params) do
    results = nil
    render(conn, "index.html", results: results)
  end
end
