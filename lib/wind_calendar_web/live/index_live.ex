defmodule WindCalendarWeb.IndexLive do
  use WindCalendarWeb.LiveView

  alias WindCalendar.Directions
  alias Surface.Components.Form

  alias Surface.Components.Form.{
    Checkbox,
    Field,
    Select,
    HiddenInput,
    Label,
    NumberInput,
    TextInput,
    TimeInput
  }

  def mount(_, _, socket) do
    initial_form =
      url_form(%{
        "unit" => "ms",
        "min_speed" => 0,
        "max_speed" => 90,
        "wind_directions" => nil,
        "indicator_direction" => "follow",
        "timezone" => "",
        "start_time" => "09:00",
        "end_time" => "21:00"
      })

    {:ok,
     socket
     |> assign(form: initial_form, url: nil, wind_direction_icon: Directions.directions())}
  end

  def render(assigns) do
    ~F"""
    <article>
      <header><strong>Create a wind calendar for your spot</strong></header>
      <Form for={@form} change="generate-url">
        <div id="map" :hook="Leaflet" phx-update="ignore">
          <Field name={:latlng}>
            <HiddenInput />
          </Field>
        </div>
        <label>Copy this url to create a new calendar</label>
        {#if !@url}
          <p aria-busy="true">Click a location on the map</p>
        {#else}
          <fieldset role="group">
            <TextInput value={@url} />
            <button type="button" id="url-copy-button" :hook="Copy" data-value={@url}>Copy</button>
          </fieldset>
        {/if}
        <div class="grid">
          <div class="grid">
            <Field name={:start_time}>
              <Label>Start time</Label>
              <TimeInput />
            </Field>
            <Field name={:end_time}>
              <Label>End time</Label>
              <TimeInput />
            </Field>
          </div>
          <Field name={:timezone}>
            <Label>Timezone</Label>
            <fieldset role="group">
              <Select options={[{"Local", ""} | Tzdata.zone_list()]} />
            </fieldset>
          </Field>
        </div>
        <div class="grid">
          <fieldset>
            <Field name={:unit}>
              <Label>Wind speed unit:</Label>
              <Select options={[{"kn (Knots)", "kn"}, {"m/s", "ms"}, {"mph", "mph"}]} />
            </Field>
            <Field name={:min_speed}>
              <Label>Minimum windspeed:</Label>
              <fieldset role="group">
                <NumberInput />
                <button disabled>{@form[:unit].value}</button>
              </fieldset>
            </Field>
            <Field name={:max_speed}>
              <Label>Maximum windspeed:</Label>
              <fieldset role="group">
                <NumberInput />
                <button disabled>{@form[:unit].value}</button>
              </fieldset>
            </Field>
          </fieldset>
          <fieldset>
            <Field name={:indicator_direction}>
              <Label>Wind indicator direction</Label>
              <Select options={[
                {"Following the wind (N): ↓", "follow"},
                {"Into the wind (N): ↑", "into"},
                {"Abbreviation: N", "abbreviation"}
              ]} />
            </Field>
            <Field name={:wind_directions}>
              <Label>Wind directions:</Label>
              <div id="wind-directions">
                {#for {value, label_map} <- @wind_direction_icon}
                  <Label>
                    {#if is_nil(@form[:wind_directions].value)}
                      <input
                        type="checkbox"
                        name="url_form[wind_directions][]"
                        id={"url_form_wind_directions-#{value}"}
                        value={value}
                        checked
                      />
                    {#else}
                      <input
                        type="checkbox"
                        name="url_form[wind_directions][]"
                        id={"url_form_wind_directions-#{value}"}
                        value={value}
                        checked={to_string(value) in @form[:wind_directions].value}
                      />
                    {/if}
                    {label_map[@form[:indicator_direction].value]}
                    {#if @form[:indicator_direction].value != "abbreviation"}
                      ({label_map["abbreviation"]})
                    {/if}
                  </Label>
                {/for}
              </div>
            </Field>
          </fieldset>
        </div>
      </Form>
      <footer>
      </footer>
    </article>
    """
  end

  def handle_event(
        "generate-url",
        %{
          "url_form" =>
            %{
              "unit" => unit,
              "latlng" => latlon,
              "indicator_direction" => indicator_direction,
              "min_speed" => min_speed,
              "max_speed" => max_speed
            } =
              params
        },
        socket
      ) do
    [lat, lon] =
      latlon
      |> String.split(",")
      |> Enum.map(&(Float.parse(&1) |> elem(0)))

    IO.inspect(params)
    # We add the timezone if it is not included in the params based on the latitude and longitude
    params =
      Map.update!(params, "timezone", fn timezone ->
        if params["clear_timezone"] == "true" or timezone == "" do
          case TzWorld.timezone_at({lon, lat}) do
            {:ok, timezone} -> timezone
            {:error, _} -> ""
          end
        else
          timezone
        end
      end)
      |> IO.inspect()

    wind_directions =
      Map.get(params, "wind_directions", [])

    url_params =
      "unit=#{unit}&lat=#{lat}&lon=#{lon}&indicator_direction=#{indicator_direction}&timezone=#{params["timezone"]}"
      |> maybe_append("min_speed", min_speed)
      |> maybe_append("max_speed", max_speed)
      |> maybe_append("wind_direction", wind_directions)

    url = "#{URI.to_string(socket.host_uri)}/spot?#{url_params}"

    {:noreply,
     socket
     |> assign(url: url, form: url_form(params))}
  end

  defp url_form(params), do: to_form(params, as: :url_form) |> IO.inspect()

  defp maybe_append(params, _key, ""), do: params

  defp maybe_append(params, key, value) when is_list(value) do
    params <> "&#{Enum.map_join(value, "&", &"#{key}[]=#{&1}")}"
  end

  defp maybe_append(params, key, value), do: params <> "&#{key}=#{value}"
end
