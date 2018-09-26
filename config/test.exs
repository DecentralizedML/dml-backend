use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dml, DmlWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :dml, Dml.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "dml_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Guardian config
config :dml, Dml.Guardian,
  issuer: "DML",
  secret_key: "NjiVL61cY+ML30sQdXtaKbyHXAYviNT6X5bb8BvrS8MeVCPb5JK7dbPLZpdlAqZV"

# Reduce bcrypt rounds
config :bcrypt_elixir, :log_rounds, 1

# Arc
config :arc,
  storage: Arc.Storage.Local

# Import secrets
import_config "dev.secret.exs"
