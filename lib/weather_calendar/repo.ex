defmodule WeatherCalendar.Repo do
  use Punkix.Repo,
    otp_app: :weather_calendar,
    adapter: Ecto.Adapters.Postgres
end
