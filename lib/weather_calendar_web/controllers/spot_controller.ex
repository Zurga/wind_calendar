defmodule WeatherCalendarWeb.SpotController do
  use WeatherCalendarWeb.Controller

  alias WeatherCalendar.WindCalendar

  def spot(conn, params) do
    serialized =
      WindCalendar.Params.new(params)
      |> WindCalendar.generate_calendar()
      |> Magical.Serializer.serialize()

    conn
    |> put_resp_content_type("text/calendar")
    |> send_resp(200, serialized)
  end
end
