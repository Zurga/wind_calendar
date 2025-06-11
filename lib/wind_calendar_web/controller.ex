defmodule WindCalendarWeb.Controller do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: WindCalendarWeb.Layouts]

      import Plug.Conn
      import WindCalendarWeb.Gettext

      unquote(WindCalendarWeb.verified_routes())
    end
  end
end
