defmodule WeatherCalendarWeb.Components.Table.Column do
  @moduledoc """
  Defines a column for the parent table component.

  The column instance is automatically added to the table's
  `cols` slot.
  """

  use WeatherCalendarWeb.Component, slot: "cols"

  @doc "Column header text"
  prop label, :string, required: true
end
