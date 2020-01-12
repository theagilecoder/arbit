defmodule Arbit.Repo do
  use Ecto.Repo,
    otp_app: :arbit,
    adapter: Ecto.Adapters.Postgres
end
