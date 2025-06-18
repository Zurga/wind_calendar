defmodule WindCalendarWeb.SpotController do
  use WindCalendarWeb.Controller

  alias Magical.{Calendar, Event}
  @all_wind_directions 0..15
  @wind_direction_icon %{
    # North
    0 => %{"into" => "↑", "follow" => "↓", "abbreviation" => "N"},
    # North-Northeast
    1 => %{"into" => "↑↗", "follow" => "↓↙", "abbreviation" => "NNE"},
    # Northeast
    2 => %{"into" => "↗", "follow" => "↙", "abbreviation" => "NE"},
    # East-Northeast
    3 => %{"into" => "→↗", "follow" => "←↙", "abbreviation" => "ENE"},
    # East
    4 => %{"into" => "→", "follow" => "←", "abbreviation" => "E"},
    # East-Southeast
    5 => %{"into" => "→↘", "follow" => "←↖", "abbreviation" => "ESE"},
    # Southeast
    6 => %{"into" => "↘", "follow" => "↖", "abbreviation" => "SE"},
    # South-Southeast
    7 => %{"into" => "↓↘", "follow" => "↑↖", "abbreviation" => "SSE"},
    # South
    8 => %{"into" => "↓", "follow" => "↑", "abbreviation" => "S"},
    # South-Southwest
    9 => %{"into" => "↓↙", "follow" => "↑↗", "abbreviation" => "SSW"},
    # Southwest
    10 => %{"into" => "↙", "follow" => "↗", "abbreviation" => "SW"},
    # West-Southwest
    11 => %{"into" => "←↙", "follow" => "→↗", "abbreviation" => "WSW"},
    # West
    12 => %{"into" => "←", "follow" => "→", "abbreviation" => "W"},
    # West-Northwest
    13 => %{"into" => "←↖", "follow" => "→↘", "abbreviation" => "WNW"},
    # Northwest
    14 => %{"into" => "↖", "follow" => "↘", "abbreviation" => "NW"},
    # North-Northwest
    15 => %{"into" => "↑↖", "follow" => "↓↘", "abbreviation" => "NNW"}
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
    wind_arrow = Map.get(params, "indicator_direction", "follow")

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
            summary: "#{trunc(wind_speed)} #{@wind_direction_icon[wind_direction][wind_arrow]}",
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
    |> text(serialized)
  end

  def forecast_url(lat, lon) do
    "https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{lon}&hourly=wind_speed_10m,wind_direction_10m,wind_gusts_10m&models=knmi_harmonie_arome_netherlands&timezone=Europe%2FBerlin&wind_speed_unit=kn"
  end

  defp normalize_degree(nil), do: nil
  defp normalize_degree(degree), do: rem(round(degree / 22.5), 16)
end
