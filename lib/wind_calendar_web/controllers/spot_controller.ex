defmodule WindCalendarWeb.SpotController do 
    use WindCalendarWeb.Controller
    def spot(conn, %{"special" => spec}) do
     text conn, spec
    end

    def spot(conn, %{"lat" => lat, "lon" => lon} = params) do
      {:ok, %{body: %{"hourly" => forecast}}} = forecast_url(lat, lon)
      |> Req.get()
      good_times = Enum.map(forecast["time"], fn datetime_string -> 
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
        windspeed = Enum.at(forecast["wind_speed_10m"], index)
        windspeed > 10 and windspeed < 20
      end)
      |> Enum.filter(fn {datetime, index} ->
        true
      end)
      

    conn
    |> text(inspect good_times)
    end
    
    def forecast_url(lat, lon) do
    "https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{lon}&hourly=wind_speed_10m,wind_direction_10m,wind_gusts_10m&models=knmi_harmonie_arome_netherlands&timezone=Europe%2FBerlin&wind_speed_unit=kn"
    end
end 