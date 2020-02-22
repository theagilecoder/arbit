defmodule ArbitWeb.CoinbasebitbnsController do
  use ArbitWeb, :controller

  alias Arbit.Track

  def index(conn, _params) do
    results = Track.list_results()
    render(conn, "index.html", results: results)
  end
end
