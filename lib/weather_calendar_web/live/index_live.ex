defmodule WeatherCalendarWeb.IndexLive do
  use WeatherCalendarWeb.LiveView

  alias WeatherCalendar.{WindCalendar, Directions, Timezone}
  alias Surface.Components.Form

  alias Surface.Components.Form.{
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
        "max_speed" => 40,
        "wind_directions" => nil,
        "indicator_direction" => "follow",
        "timezone" => "",
        "start_time" => "09:00:00",
        "end_time" => "21:00:00"
      })

    directions = Directions.directions()
    abbreviations = directions |> Map.values() |> Enum.map(& &1["abbreviation"])

    {:ok,
     socket
     |> assign(
       form: initial_form,
       url: nil,
       wind_direction_icon: Directions.directions(),
       calendar_events: Map.new(),
       wind_direction_labels: abbreviations,
       selected_wind_directions: Directions.directions()
     )}
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
            <Label>Wind directions:</Label>
            <div id="wind-compass" class="wind-compass-container" :hook="WindCompassHook" phx-update="ignore">
              <canvas id="wind-directions" class="wind-compass-canvas" width="512" height="512" />
              <Field name={:wind_directions}>
                <HiddenInput />
              </Field>
            </div>
          </fieldset>
        </div>
      </Form>
      <footer>
        <h3>Preview</h3>

        <table>
          <thead>
            <tr>
              {#for date <- Map.keys(@calendar_events)}
                <th>{date}</th>
              {/for}
            </tr>
          </thead>
          <tbody>
            {#for time <- all_times(@calendar_events)}
              <tr>
                {#for date <- Map.keys(@calendar_events)}
                  <td>
                    {#for event <- events_at_time(@calendar_events[date], time)}
                      <div>
                        <strong>{Calendar.strftime(event.dtstart, "%H:%M")}</strong>:
                        {event.summary}
                      </div>
                    {/for}
                  </td>
                {/for}
              </tr>
            {/for}
          </tbody>
        </table>
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

    # We add the timezone if it is not included in the params based on the latitude and longitude
    params =
      Map.update!(params, "timezone", fn timezone ->
        if params["clear_timezone"] == "true" or timezone == "" do
          [lat, lon] =
            [lat, lon]
            |> Enum.map(&(Float.parse(&1) |> elem(0)))

          Timezone.at!(lat, lon)
        else
          timezone
        end
      end)
      |> Map.put("lat", lat)
      |> Map.put("lon", lon)
      |> normalize_time(~w/start_time end_time/)

    wind_directions =
      Map.get(params, "wind_directions", [])
      |> String.split(",")
      |> Enum.map(&Directions.abbreviation_to_index/1)
      |> Enum.reject(&is_nil/1)

    url_params =
      "unit=#{unit}&lat=#{lat}&lon=#{lon}&indicator_direction=#{indicator_direction}&timezone=#{params["timezone"]}"
      |> maybe_append("min_speed", min_speed)
      |> maybe_append("max_speed", max_speed)
      |> maybe_append("wind_direction", wind_directions)

    url = "#{URI.to_string(socket.host_uri)}/spot?#{url_params}"

    grouped_events =
      WindCalendar.Params.new(params)
      |> WindCalendar.generate_calendar()
      |> group_events_by_date()

    {:noreply,
     socket
     |> assign(
       url: url,
       form: url_form(params),
       calendar_events: grouped_events
     )}
  end

  defp url_form(params), do: to_form(params, as: :url_form)

  defp maybe_append(params, _key, ""), do: params

  defp maybe_append(params, key, value) when is_list(value) do
    params <> "&#{Enum.map_join(value, "&", &"#{key}[]=#{&1}")}"
  end

  defp maybe_append(params, key, value), do: params <> "&#{key}=#{value}"

  defp events_at_time(events, time) do
    Enum.filter(events, fn event ->
      DateTime.to_time(event.dtstart) == time
    end)
  end

  defp group_events_by_date(%{events: events}) do
    events
    |> Enum.group_by(&DateTime.to_date(&1.dtstart))
  end

  defp all_times(grouped_events) do
    grouped_events
    |> Map.values()
    |> List.flatten()
    |> Enum.map(&DateTime.to_time(&1.dtstart))
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp normalize_time(params, keys) do
    Enum.reduce(keys, params, fn key, acc ->
      Map.update!(acc, key, fn
        "" ->
          ""

        time ->
          if String.length(time) < 6 do
            time <> ":00"
          else
            time
          end
      end)
    end)
  end
end
