defmodule ArbitWeb.ResultController do
  use ArbitWeb, :controller

  alias Arbit.Track

  def index(conn, _params) do
    results = Track.list_results()
    render(conn, "index.html", results: results)
  end

  def show(conn, _params) do
    results = Track.list_results()
    render(conn, "show.html", results: results)
  end
end
