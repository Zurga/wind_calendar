defmodule WindCalendarWeb.LiveView do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Surface.LiveView,
        layout: {WindCalendarWeb.Layouts, :app}

      unquote(WindCalendarWeb.html_helpers())
    end
  end
end
