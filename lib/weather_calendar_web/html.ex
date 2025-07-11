defmodule WeatherCalendarWeb.HTML do
  defmacro __using__(_) do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(WeatherCalendarWeb.html_helpers())
    end
  end
end
