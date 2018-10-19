# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :dml,
  ecto_repos: [Dml.Repo]

# Configures the endpoint
config :dml, DmlWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lOQqH2L88+whaaP7IeI4ZuZc1R2H0CKCO02657XSSKFwjjtO4nHfb/Qaoeu6cAyL",
  render_errors: [view: DmlWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Dml.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# CORS
config :cors_plug,
  origin: [
    "http://localhost:3000",
    "http://localhost:4000",
    "https://elegant-brisk-indianjackal.gigalixirapp.com",
    "https://clever-davinci-c72572.netlify.com"
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
