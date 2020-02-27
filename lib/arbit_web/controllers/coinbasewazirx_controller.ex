defmodule ArbitWeb.CoinbasewazirxController do
  use ArbitWeb, :controller
  alias Arbit.Display

  def index(conn, _params) do
    results = Display.list_coinbasewazirx()
    render(conn, "index.html", results: results)
  end
end
