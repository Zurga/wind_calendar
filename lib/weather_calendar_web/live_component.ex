defmodule WeatherCalendarWeb.LiveComponent do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Surface.LiveComponent

      unquote(WeatherCalendarWeb.html_helpers())
    end
  end
end
