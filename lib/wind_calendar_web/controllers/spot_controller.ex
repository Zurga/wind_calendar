defmodule WindCalendarWeb.SpotController do
  use WindCalendarWeb.Controller

  alias WindCalendar.Directions
  alias WindCalendar.Forecasters.KNMISeamless
  alias Magical.{Calendar, Event}
  @all_wind_directions 0..15

  def spot(
        conn,
        %{"lat" => lat, "lon" => lon} = params
      ) do
    acceptable_wind_directions =
      case Map.get(params, "wind_direction") do
        nil -> @all_wind_directions
        directions -> Enum.map(directions, &String.to_integer/1)
      end

    min_speed = Map.get(params, "min_speed", "0") |> String.to_integer()
    max_speed = Map.get(params, "max_speed", "9999") |> String.to_integer()
    wind_direction_format = Map.get(params, "indicator_direction", "follow")
    # ms, kn, mph 
    unit = Map.get(params, "unit", "ms")
    start_time = Map.get(params, "start_time", "08:00:00") |> Time.from_iso8601!()
    end_time = Map.get(params, "end_time", "20:00:00") |> Time.from_iso8601!()
    timezone = Map.get(params, "timezone")

    # FIXME add forecaster based on either params or the lat and lon. 
    %{
      "time" => datetimes,
      "wind_speed_10m" => wind_speeds,
      "wind_direction_10m" => wind_directions
    } = KNMISeamless.get_forecast(lat, lon, unit, timezone)

    calendar =
      Enum.map(datetimes, fn datetime_string ->
        # FIXME Maybe add timezone here
        {:ok, datetime, 0} = DateTime.from_iso8601(datetime_string <> ":00Z")
        datetime
      end)
      |> Enum.with_index()
      |> Enum.reduce(%Calendar{}, fn {datetime, index}, %{events: events} = calendar ->
        time = DateTime.to_time(datetime)
        wind_speed = Enum.at(wind_speeds, index)
        wind_direction = Enum.at(wind_directions, index) |> normalize_degree()

        if time.hour >= start_time.hour and time.hour <= end_time.hour and wind_speed > min_speed and
             wind_speed < max_speed and
             wind_direction in acceptable_wind_directions do
          event = %Event{
            summary:
              "#{trunc(wind_speed)} #{Directions.as_string(wind_direction, wind_direction_format)}",
            dtstart: datetime,
            dtend: datetime
          }

          %{calendar | events: [event | events]}
        else
          calendar
        end
      end)

    serialized = Magical.Serializer.serialize(calendar)

    conn
    |> put_resp_content_type("text/calendar")
    |> send_resp(200, serialized)
  end

  defp normalize_degree(nil), do: nil
  defp normalize_degree(degree), do: rem(round(degree / 22.5), 16)
end
