defmodule WindCalendarWeb.SpotController do
  use WindCalendarWeb.Controller

  alias Magical.{Calendar, Event}
  @all_wind_directions 0..15
  @wind_direction_icon %{
    # North
    0 => "↑",
    # North-Northeast
    1 => "↗↑",
    # Northeast
    2 => "↗",
    # East-Northeast
    3 => "↗→",
    # East
    4 => "→",
    # East-Southeast
    5 => "↘→",
    # Southeast
    6 => "↘",
    # South-Southeast
    7 => "↘↓",
    # South
    8 => "↓",
    # South-Southwest
    9 => "↙↓",
    # Southwest
    10 => "↙",
    # West-Southwest
    11 => "↙←",
    # West
    12 => "←",
    # West-Northwest
    13 => "↖←",
    # Northwest
    14 => "↖",
    # North-Northwest
    15 => "↖↑"
  }

  def spot(conn, %{"special" => spec}) do
    text(conn, spec)
  end

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

    {:ok,
     %{
       body: %{
         "hourly" => %{
           "time" => datetimes,
           "wind_speed_10m" => wind_speeds,
           "wind_direction_10m" => wind_directions
         }
       }
     }} = Req.get(forecast_url(lat, lon))

    calendar =
      Enum.map(datetimes, fn datetime_string ->
        {:ok, datetime, 0} = DateTime.from_iso8601(datetime_string <> ":00Z")
        datetime
      end)
      |> Enum.with_index()
      |> Enum.reduce(%Calendar{}, fn {datetime, index}, %{events: events} = calendar ->
        time = DateTime.to_time(datetime)
        wind_speed = Enum.at(wind_speeds, index)
        wind_direction = Enum.at(wind_directions, index) |> normalize_degree()

        if time.hour > 8 and time.hour < 20 and wind_speed > min_speed and wind_speed < max_speed and
             wind_direction in acceptable_wind_directions do
          event = %Event{
            summary: "#{trunc(wind_speed)} #{@wind_direction_icon[wind_direction]}",
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

  def forecast_url(lat, lon) do
    "https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{lon}&hourly=wind_speed_10m,wind_direction_10m,wind_gusts_10m&models=knmi_harmonie_arome_netherlands&timezone=Europe%2FBerlin&wind_speed_unit=kn"
  end

  defp normalize_degree(nil), do: nil
  defp normalize_degree(degree), do: rem(round(degree / 22.5), 16)
end
