defmodule WindCalendar.Forecasters.KNMISeamless do
  @variables ~w/cloud_cover visibility wind_speed_10m wind_direction_10m wind_gusts_10m surface_temperature rain/
  def get_forecast(lat, lon, unit, timezone) do
    {:ok,
     %{
       body: %{
         "hourly" => hourly
       }
     }} = Req.get(forecast_url(lat, lon, unit, timezone))

    hourly
  end

  defp forecast_url(lat, lon, unit, timezone) do
    "https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{lon}&hourly=#{Enum.join(@variables, ",")}&models=knmi_seamless&wind_speed_unit=#{unit}&timezone=#{timezone}"
    |> IO.inspect()
  end
end
