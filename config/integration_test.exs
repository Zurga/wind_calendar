import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :wind_calendar, WindCalendar.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "wind_calendar_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :wind_calendar, WindCalendarWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "7aTM5VdxWGizHYx12YNd9vok/VYGSuEecTaH21GX5KAAsWGefEH+wdCHKxpy6oJ5",
  server: true

# In test we don't send emails.
config :wind_calendar, WindCalendar.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# For Wallaby
config :wallaby,
  otp_app: :wind_calendar,
  screenshot_dir: "/tmp/",
  screenshot_on_failure: true,
  js_logger: nil

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
