defmodule ArbitWeb.DashboardController do
  use ArbitWeb, :controller
  alias Arbit.Display

  def index(conn, _params) do
    results = Display.list_dashboard()
    render(conn, "index.html", results: results)
  end
end
