defmodule WeatherCalendarWeb.LiveView do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Surface.LiveView,
        layout: {WeatherCalendarWeb.Layouts, :app}

      unquote(WeatherCalendarWeb.html_helpers())
    end
  end
end
