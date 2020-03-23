defmodule ArbitWeb.Pow.Routes do
  use Pow.Phoenix.Routes
  alias ArbitWeb.Router.Helpers, as: Routes

  def after_sign_in_path(conn), do: Routes.coinbasebitbns_path(conn, :index)
  def after_sign_out_path(conn), do: Routes.page_path(conn, :index)
end
