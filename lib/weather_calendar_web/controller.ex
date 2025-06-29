defmodule WeatherCalendarWeb.Controller do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: WeatherCalendarWeb.Layouts]

      import Plug.Conn
      import WeatherCalendarWeb.Gettext

      unquote(WeatherCalendarWeb.verified_routes())
    end
  end
end
