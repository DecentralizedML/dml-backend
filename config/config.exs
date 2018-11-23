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

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason
# config :phoenix, :format_encoders, json: ProperCase.JSONEncoder.CamelCase
config :phoenix, :filter_parameters, [
  "password",
  "jwt",
  "private_key",
  "privateKey",
  "security_answer1",
  "securityAnswer1",
  "security_answer2",
  "securityAnswer2"
]

# CORS
config :cors_plug,
  origin: "*"

# Sentry
config :sentry,
  dsn: System.get_env("SENTRY_DSN") || "https://public_key@app.getsentry.com/1",
  included_environments: ~w(production staging),
  environment_name: System.get_env("SENTRY_ENV") || "development",
  enable_source_code_context: true,
  root_source_code_path: File.cwd!()

# JSONAPI
config :jsonapi,
  remove_links: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
