# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :weather_calendar,
  ecto_repos: [WeatherCalendar.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :weather_calendar, WeatherCalendarWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: WeatherCalendarWeb.ErrorHTML, json: WeatherCalendarWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: WeatherCalendar.PubSub,
  live_view: [signing_salt: "5riiwxFq"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :weather_calendar, WeatherCalendar.Mailer, adapter: Swoosh.Adapters.Local

config :tzdata, :data_dir, "/tmp"
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase
config :tz_world, backend: TzWorld.Backend.EtsWithIndexCache, data_dir: "/tmp"

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  weather_calendar: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  catalogue: [
    args:
      ~w(../deps/surface_catalogue/assets/js/app.js --bundle --target=es2016 --minify --outdir=../priv/static/assets/catalogue),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :surface, :components, [
  {WeatherCalendarWeb.Components.Table, propagate_context_to_slots: true}
]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
