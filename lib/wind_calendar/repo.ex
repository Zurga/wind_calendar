defmodule WindCalendar.Repo do
  use Punkix.Repo,
    otp_app: :wind_calendar,
    adapter: Ecto.Adapters.Postgres
end
