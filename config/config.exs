# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :arbit,
  ecto_repos: [Arbit.Repo]

# Configures the endpoint
config :arbit, ArbitWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "IIUW9uOXRsC7+IdzPP7TBKvdIs6hZ2RzSnt4J7jzgMwafSsGnXm9Kk87Uv7zVC5S",
  render_errors: [view: ArbitWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Arbit.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures Pow Auth
config :arbit, :pow,
  user: Arbit.Users.User,
  repo: Arbit.Repo

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
