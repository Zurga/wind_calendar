defmodule WeatherCalendar.Forecasters do
  @variables ~w/cloud_cover visibility wind_speed_10m wind_direction_10m wind_gusts_10m surface_temperature rain/
  @models %{"knmi_seamless" => [56.0, 11.28, 49.00, 0.0]}

  def get_model(lat, lon) do
    Enum.filter(@models, fn {_model, geofence} ->
      [north, east, south, west] = geofence

      lon > west and lon < east and lat < north and lat > south
    end)
    |> Enum.at(0)
    |> elem(0)
  end

  def forecast(lat, lon, unit, timezone, variables \\ @variables) do
    model = get_model(lat, lon)

    url =
      forecast_url(model, lat, lon, unit, timezone, variables)
      |> IO.inspect()

    {:ok, %{body: %{"hourly" => hourly}}} = Req.get(url)

    hourly
  end

  def forecast_url(model, lat, lon, unit, timezone, variables \\ @variables) do
    "https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{lon}&hourly=#{Enum.join(variables, ",")}&models=#{model}&wind_speed_unit=#{unit}&timezone=#{timezone}"
  end
end
