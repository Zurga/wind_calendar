defmodule WindCalendarWeb.IndexLive do
  use WindCalendarWeb.LiveView

  alias Surface.Components.Form
  alias Surface.Components.Form.{Checkbox, Field, Select, HiddenInput, Label, NumberInput}

  @wind_direction_icon %{
    # North
    0 => %{"into" => "↑", "follow" => "↓", "abbreviation" => "N"},
    # North-Northeast
    1 => %{"into" => "↑↗", "follow" => "↓↙", "abbreviation" => "NNE"},
    # Northeast
    2 => %{"into" => "↗", "follow" => "↙", "abbreviation" => "NE"},
    # East-Northeast
    3 => %{"into" => "→↗", "follow" => "←↙", "abbreviation" => "ENE"},
    # East
    4 => %{"into" => "→", "follow" => "←", "abbreviation" => "E"},
    # East-Southeast
    5 => %{"into" => "→↘", "follow" => "←↖", "abbreviation" => "ESE"},
    # Southeast
    6 => %{"into" => "↘", "follow" => "↖", "abbreviation" => "SE"},
    # South-Southeast
    7 => %{"into" => "↓↘", "follow" => "↑↖", "abbreviation" => "SSE"},
    # South
    8 => %{"into" => "↓", "follow" => "↑", "abbreviation" => "S"},
    # South-Southwest
    9 => %{"into" => "↓↙", "follow" => "↑↗", "abbreviation" => "SSW"},
    # Southwest
    10 => %{"into" => "↙", "follow" => "↗", "abbreviation" => "SW"},
    # West-Southwest
    11 => %{"into" => "←↙", "follow" => "→↗", "abbreviation" => "WSW"},
    # West
    12 => %{"into" => "←", "follow" => "→", "abbreviation" => "W"},
    # West-Northwest
    13 => %{"into" => "←↖", "follow" => "→↘", "abbreviation" => "WNW"},
    # Northwest
    14 => %{"into" => "↖", "follow" => "↘", "abbreviation" => "NW"},
    # North-Northwest
    15 => %{"into" => "↑↖", "follow" => "↓↘", "abbreviation" => "NNW"}
  }

  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(
       form:
         to_form(
           %{"unit" => "ms", "min_speed" => nil, "max_speed" => nil, "wind_directions" => nil},
           as: :url_form
         )
         |> IO.inspect(label: :form)
     )
     |> assign(url: nil)
     |> assign(wind_direction_icon: @wind_direction_icon)}
  end

  def render(assigns) do
    ~F"""
    <Form for={@form} change="generate-url">
      <div id="map" :hook="Leaflet" phx-update="ignore">
        <Field name={:latlng}>
          <HiddenInput />
        </Field>
      </div>
      <fieldset>
        <Field name={:unit}>
          <Label>Wind speed unit</Label>
          <Select options={[{"kn (Knots)", "kn"}, {"m/s", "ms"}, {"mph", "mph"}]} />
        </Field>
        <Field name={:indicator_direction}>
          <Label>Wind indicator direction</Label>
          <Select options={~w/follow into abbreviation/} />
        </Field>
        <Field name={:wind_directions}>
          {#for {value, label_map} <- @wind_direction_icon}
            <Label>{label_map["abbreviation"]}</Label>
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
          {/for}
        </Field>
        <Field name={:min_speed}>
          <Label>Minimal windspeed</Label>
          <fieldset role="group">
            <NumberInput />
            <button disabled>{@form[:unit].value}</button>
          </fieldset>
        </Field>
        <Field name={:max_speed}>
          <Label>Maximum windspeed</Label>
          <fieldset role="group">
            <NumberInput />
            <button disabled>{@form[:unit].value}</button>
          </fieldset>
        </Field>
      </fieldset>
    </Form>
    <pre :if={@url}>
      {@url}
    </pre>
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
    [lat, lon] = String.split(latlon || ",", ",")

    wind_directions =
      Map.get(params, "wind_directions", [])

    url_params =
      "unit=#{unit}&lat=#{lat}&lon=#{lon}&indicator_direction=#{indicator_direction}"
      |> maybe_append("min_speed", min_speed)
      |> maybe_append("max_speed", max_speed)
      |> maybe_append("wind_direction", wind_directions)

    url = "#{WindCalendarWeb.Endpoint.host()}/spot?#{url_params}"

    {:noreply,
     socket
     |> assign(url: url)
     |> assign(form: to_form(params, as: "url_form") |> IO.inspect(label: :changed))}
  end

  defp generate_url(lat, lon, unit, indicator_direction) do
  end

  defp maybe_append(params, key, ""), do: params

  defp maybe_append(params, key, value) when is_list(value) do
    params <> "&#{Enum.map_join(value, "&", &"#{key}[]=#{&1}")}"
  end

  defp maybe_append(params, key, value), do: params <> "&#{key}=#{value}"
end
