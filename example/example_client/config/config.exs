# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :example_client,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :example_client, ExampleClientWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ExampleClientWeb.ErrorHTML, json: ExampleClientWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ExampleClient.PubSub,
  live_view: [signing_salt: "Hic/NtzY"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  example_client: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  example_client: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# OIDC Provider configuration
config :example_client,
  provider_url: "http://localhost:4000",
  client_id: System.get_env("OIDC_CLIENT_ID") || "example_client",
  client_secret: System.get_env("OIDC_CLIENT_SECRET") || "example_secret",
  redirect_uri: "http://localhost:4001/auth/callback"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
