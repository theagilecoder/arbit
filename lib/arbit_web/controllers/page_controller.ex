defmodule ArbitWeb.PageController do
  use ArbitWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
