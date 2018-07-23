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
  secret_key_base: "hPuE6GMo3hEjHF9/NMiUhivA5LPQJKW4rfT/sH8WLw+r0g7Ud/L02myD0j+zt/D+",
  render_errors: [view: DmlWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Dml.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
