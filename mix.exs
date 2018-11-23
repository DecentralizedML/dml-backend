defmodule Dml.Mixfile do
  use Mix.Project

  def project do
    [
      app: :dml,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        coverage: :test,
        check: :test,
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Dml.Application, []},
      extra_applications: [:sentry, :logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:ecto_sql, "~> 3.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:jason, "~> 1.0"},
      {:postgrex, ">= 0.0.0"},
      {:gettext, "~> 0.11"},
      # TODO: Upgrade to 2.x when possible
      {:plug_cowboy, "~> 1.0"},
      {:plug, "~> 1.7"},
      {:comeonin, "~> 4.1"},
      {:bcrypt_elixir, "~> 1.1"},
      {:guardian, "~> 1.0"},
      {:bodyguard, "~> 2.2"},
      {:oauth2, "~> 0.9"},
      {:machinery, github: "joaomdmoura/machinery"},
      {:arc, "~> 0.11"},
      {:arc_ecto, "~> 0.11"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:sweet_xml, "~> 0.6"},
      {:cors_plug, "~> 2.0"},
      {:jsonapi, github: "jeregrine/jsonapi"},
      {:proper_case, "~> 1.0"},
      {:countries, "~> 1.5"},

      # Error tracking
      {:sentry, "~> 7.0"},

      # Test environment
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.7", only: [:dev, :test], runtime: false},
      {:ex_machina, "~> 2.2", only: :test},
      {:excoveralls, "~> 0.10", only: :test},
      {:faker, "~> 0.10", only: :test},
      {:exvcr, "~> 0.10", only: :test},

      # Deploy
      {:distillery, "~> 2.0", warn_missing: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      check: ["test", "credo", "sobelow --compact --quiet -i Config.HTTPS --ignore-files config/prod.secret.exs"],
      coverage: ["coveralls.html", &open_coverage_report/1]
    ]
  end

  defp open_coverage_report(_) do
    Mix.shell().cmd("open cover/excoveralls.html")
  end
end
