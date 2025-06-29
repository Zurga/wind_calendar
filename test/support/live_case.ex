defmodule WeatherCalendarWeb.LiveCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a LiveView and are tested using Wallaby.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use WeatherCalendarWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using opts do
    quote do
      # The default endpoint for testing
      @endpoint WeatherCalendarWeb.Endpoint

      unquote(WeatherCalendarWeb.verified_routes())

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import WeatherCalendarWeb.LiveCase

      # Wallaby related imports
      import Wallaby.Query,
        only: [button: 1, css: 1, css: 2, fillable_field: 1, select: 1, text: 1]

      import Wallaby.Browser, only: [take_screenshot: 1, take_screenshot: 2]
    end
  end

  def fill_form(session, attrs) do
    Enum.reduce(attrs, session, fn {field, value}, session ->
      Wallaby.Browser.set_value(session, field, value)
    end)
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
