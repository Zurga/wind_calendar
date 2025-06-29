defmodule WeatherCalendar do
  @moduledoc """
  WeatherCalendar keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  use Boundary, deps: [], exports: []
  alias Magical.{Calendar, Event}

  @spec generate_calendar(any(), Time.t(), Time.t(), any(), any()) :: Magical.Calendar.t()
  def generate_calendar(forecast, %Time{} = start_time, %Time{} = end_time, formatter, filters) do
    {datetimes, forecast} = Map.pop(forecast, "time")

    datetimes
    |> Enum.with_index()
    |> Enum.reduce(%Calendar{}, fn {datetime_string, index}, %{events: events} = calendar ->
      # FIXME Maybe add timezone here
      {:ok, datetime, 0} = DateTime.from_iso8601(datetime_string <> ":00Z")

      time = DateTime.to_time(datetime)

      if time >= start_time and time <= end_time do
        variables = apply_filters(forecast, index, filters)

        if not is_nil(variables) do
          event = %Event{
            summary: formatter.(variables),
            dtstart: datetime,
            dtend: datetime
          }

          %{calendar | events: [event | events]}
        else
          calendar
        end
      else
        calendar
      end
    end)
  end

  defp apply_filters(forecast, index, filters) do
    Enum.reduce_while(filters, %{}, fn {key, filter_func}, acc ->
      value =
        get_in(forecast, [key, Access.at(index)])

      if not is_nil(value) and filter_func.(value) do
        {:cont, Map.put(acc, key, value)}
      else
        {:halt, nil}
      end
    end)
  end
end
