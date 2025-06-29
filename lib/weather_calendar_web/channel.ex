defmodule WeatherCalendarWeb.Channel do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Phoenix.Channel
    end
  end
end
