defmodule WeatherCalendarWeb.Components.WindRose do
  use WeatherCalendarWeb.Component
  use Surface.Components.Form.HiddenInput

  prop id, :string

  def render(assigns) do
    ~F"""
    <div {=@id} phx-update="ignore" :hook>
      <canvas height="350vh" />
      <button type="button" style="display:none;">Reset to Full Circle</button>
      <HiddenInput />
    </div>
    """
  end
end
