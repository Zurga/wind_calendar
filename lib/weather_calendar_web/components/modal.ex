defmodule WeatherCalendarWeb.Components.Modal do
  use WeatherCalendarWeb.Component

  prop id, :string, required: true
  prop show, :boolean
  prop on_cancel, :fun
  slot default
  slot title
  slot footer

  def render(assigns) do
    ~F"""
    <dialog {=@id} open={@show}>
      <article>
        <header>
          <button type="button" rel="prev" :on-click={@on_cancel || open_or_close(@id)}>Close</button>
          <#slot {@title} />
        </header>
        <#slot />
        <footer :if={slot_assigned?(@footer)}>
          <#slot {@footer} />
        </footer>
      </article>
    </dialog>
    """
  end

  def open_or_close(dialog_id) do
    JS.toggle_attribute({"open", "true", "false"}, to: "##{dialog_id}")
  end
end
