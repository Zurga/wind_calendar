defmodule WeatherCalendar.CalendarPreview do
  @moduledoc """
  Parses ICS data and groups calendar events by date and hour.
  """

  def fetch_and_parse_ics(url) do
    IO.inspect("fetch spot related calendar ics")

    case Req.get(url) do
      {:ok, %{status: 200, body: body}} ->
        body

      # |> parse_ics

      _ ->
        "Error fetching ICS"
    end
  end
end
