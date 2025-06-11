defmodule WindCalendarWeb.LiveComponent do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Surface.LiveComponent

      unquote(WindCalendarWeb.html_helpers())
    end
  end
end
