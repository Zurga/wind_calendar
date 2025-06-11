defmodule WindCalendarWeb.Component do
  @moduledoc false
  defmacro __using__(opts) do
    quote do
      use Surface.Component, unquote(opts)

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      unquote(WindCalendarWeb.html_helpers())
    end
  end
end
