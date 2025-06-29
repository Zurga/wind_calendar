defmodule WeatherCalendar.Timezone do
  def at!(lat, lon) do
    case TzWorld.timezone_at({lon, lat}) do
      {:ok, timezone} -> timezone
      {:error, timezone} -> raise "No timezone for #{inspect({lat, lon})}"
    end
  end

  def at(lat, lon), do: TzWorld.timezone_at({lon, lat})
end
