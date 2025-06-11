defmodule WindCalendarWeb do
  @moduledoc """
  Contains the helper functions that will be used in other modules that define the different parts of the web subsystem.
  """
  use Boundary, deps: [WindCalendar], exports: [WindCalendarWeb.Endpoint]

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      import WindCalendarWeb.Gettext
      import Punkix.Web, only: [sigil_a: 2, on_create: 1, on_create: 2, on_update: 1, on_update: 2, maybe_patch_and_flash: 4]

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: WindCalendarWeb.Endpoint,
        router: WindCalendarWeb.Router,
        statics: WindCalendarWeb.static_paths()
    end
  end
end
