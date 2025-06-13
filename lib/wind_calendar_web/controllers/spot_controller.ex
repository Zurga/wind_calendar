defmodule WindCalendarWeb.SpotController do
  use WindCalendarWeb.Controller

  def spot(conn, %{"special" => spec}) do
    text(conn, spec)
  end

  def spot(conn, %{"lat" => lat, "lon" => lon} = params) do
    {:ok, %{body: %{"hourly" => forecast}}} =
      forecast_url(lat, lon)
      |> Req.get()
      |> IO.inspect()

    good_times =
      Enum.map(forecast["time"], fn datetime_string ->
        {:ok, datetime, 0} = DateTime.from_iso8601(datetime_string <> ":00Z")
        datetime
      end)
      |> IO.inspect()
      |> Enum.with_index()
      |> Enum.filter(fn {datetime, index} ->
        time = DateTime.to_time(datetime)
        time.hour > 8 and time.hour < 20
      end)
      |> Enum.filter(fn {datetime, index} ->
        windSpeed = Enum.at(forecast["wind_speed_10m"], index)
        windSpeed > 10 and windSpeed < 35
      end)
      |> IO.inspect()
      |> Enum.filter(fn {datetime, index} ->
        windDirection = Enum.at(forecast["wind_direction_10m"], index)
        windDirection < 38 or windDirection > 180
      end)
      |> IO.inspect()

    conn
    |> put_resp_content_type("text/calendar")
    |> send_resp(200, format_ics_events(good_times, forecast))
  end

  def forecast_url(lat, lon) do
    "https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{lon}&hourly=wind_speed_10m,wind_direction_10m,wind_gusts_10m&models=knmi_harmonie_arome_netherlands&timezone=Europe%2FBerlin&wind_speed_unit=kn"
  end

  defp format_ics_events(good_times, forecast) do
    vevents =
      Enum.map(good_times, fn {datetime, index} ->
        wind_speed = Enum.at(forecast["wind_speed_10m"], index)
        wind_dir = Enum.at(forecast["wind_direction_10m"], index)

        dt_start = DateTime.to_iso8601(datetime)
        dt_end = datetime |> DateTime.add(3600, :second) |> DateTime.to_iso8601()

        """
        BEGIN:VEVENT
        UID:#{UUID.uuid4()}@mysurfspot
        DTSTAMP:#{DateTime.utc_now() |> DateTime.to_iso8601() |> String.replace(~r/[-:]/, "") |> String.replace("Z", "")}
        DTSTART:#{ics_time_format(dt_start)}
        DTEND:#{ics_time_format(dt_end)}
        SUMMARY:Wingen Wijk aan Zee wind:#{wind_speed}knopen richting: #{wind_dir}°
        DESCRIPTION:Wind Speed: #{wind_speed} \\nWind Direction: #{wind_dir}°
        END:VEVENT
        """
      end)

    """
    BEGIN:VCALENDAR
    VERSION:2.0
    PRODID:-//mysurfspot//EN
    #{Enum.join(vevents, "\n")}
    END:VCALENDAR
    """
  end

  defp ics_time_format(datetime_str) do
    # Converts ISO8601 -> ICS format: "2025-06-14T16:00:00Z" -> "20250614T160000Z"
    datetime_str
    |> String.replace(~r/[-:]/, "")
    |> String.replace("T", "T")
  end
end
