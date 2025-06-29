defmodule WeatherCalendar.WindCalendar do
  alias WeatherCalendar.{Directions, Forecasters, Timezone}

  defmodule Params do
    @all_wind_directions 0..15
    defstruct ~w/lat lon unit start_time end_time timezone min_speed max_speed wind_direction_format acceptable_wind_directions/a

    def new(%{"lat" => lat, "lon" => lon} = params) do
      acceptable_wind_directions =
        case Map.get(params, "wind_direction") do
          nil -> @all_wind_directions
          directions -> Enum.map(directions, &String.to_integer/1)
        end

      [lat, lon] = Enum.map([lat, lon], &(Float.parse(&1) |> elem(0)))

      params = drop_empty_values(params)

      %__MODULE__{
        lat: lat,
        lon: lon,
        unit: Map.get(params, "unit", "ms"),
        start_time: Map.get(params, "start_time", "00:00:00") |> Time.from_iso8601!(),
        end_time: Map.get(params, "end_time", "23:59:59") |> Time.from_iso8601!(),
        timezone: Map.get_lazy(params, "timezone", fn -> Timezone.at!(lat, lon) end),
        min_speed: Map.get(params, "min_speed", "0") |> String.to_integer(),
        max_speed: Map.get(params, "max_speed", "9999") |> String.to_integer(),
        wind_direction_format: Map.get(params, "indicator_direction", "follow"),
        acceptable_wind_directions: acceptable_wind_directions
      }
    end

    defp drop_empty_values(params) do
      Enum.reduce(params, %{}, fn
        {_, ""}, acc ->
          acc

        {key, value}, acc ->
          Map.put(acc, key, value)
      end)
    end
  end

  def generate_calendar(%Params{
        lat: lat,
        lon: lon,
        start_time: start_time,
        end_time: end_time,
        timezone: timezone,
        min_speed: min_speed,
        max_speed: max_speed,
        wind_direction_format: wind_direction_format,
        # ms, kn, mph
        unit: unit,
        acceptable_wind_directions: acceptable_wind_directions
      }) do
    filters = %{
      "wind_speed_10m" => &(&1 >= min_speed and &1 <= max_speed),
      "wind_direction_10m" => &(Directions.normalize_degree(&1) in acceptable_wind_directions)
    }

    formatter = fn forecast ->
      wind_speed = forecast["wind_speed_10m"]

      wind_direction =
        forecast["wind_direction_10m"]
        |> Directions.normalize_degree()
        |> Directions.as_string(wind_direction_format)

      "#{trunc(wind_speed)} #{wind_direction}"
    end

    # FIXME add forecaster based on either params or the lat and lon.
    Forecasters.forecast(lat, lon, unit, timezone, ~w/wind_speed_10m wind_direction_10m/)
    |> WeatherCalendar.generate_calendar(start_time, end_time, formatter, filters)
  end
end
