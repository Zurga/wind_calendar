defmodule WeatherCalendarWeb.Components.WindDirection do
  use WeatherCalendarWeb.Component

  prop wind_direction_labels, :list, required: true
  prop selected_wind_directions, :list, required: true

  def render(assigns) do
    assigns =
      assign(assigns,
        wind_direction_labels_json: Jason.encode!(assigns.wind_direction_labels),
        selected_wind_directions_json: Jason.encode!(assigns.selected_wind_directions)
      )

    windDirection = assigns.wind_direction_labels

    ~F"""
    <h1>{windDirection}</h1>
    <h2>{@wind_direction_labels}</h2>

    <div class="wind-compass-container">
      <canvas id="compass" class="wind-compass-canvas" width="512" height="512" />
      <script>
      const windDirectionLabels = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
      const canvas = document.getElementById("compass");
      const ctx = canvas.getContext("2d");
      const centerX = canvas.width / 2;
      const centerY = canvas.height / 2;
      const radius = 200;

      // Store label bounding boxes for click detection
      const labelHitboxes = [];

      const degToRad = (deg) => (deg - 90) * (Math.PI / 180);

      function drawCompass() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        labelHitboxes.length = 0;

        // Draw ticks
        for (let i = 0; i < 360; i += 10) {
          const angle = degToRad(i);
          let length = 5;
          ctx.lineWidth = 1;

          if (i % 90 === 0) {
            length = 20;
            ctx.lineWidth = 3;
          } else if (i % 30 === 0) {
            length = 12;
            ctx.lineWidth = 2;
          }

          const x1 = centerX + Math.cos(angle) * (radius - length);
          const y1 = centerY + Math.sin(angle) * (radius - length);
          const x2 = centerX + Math.cos(angle) * radius;
          const y2 = centerY + Math.sin(angle) * radius;

          ctx.beginPath();
          ctx.moveTo(x1, y1);
          ctx.lineTo(x2, y2);
          ctx.stroke();

          // Degree labels every 10 degrees
          if (i % 10 === 0) {
            ctx.font = "12px sans-serif";
            ctx.fillStyle = "black";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            const tx = centerX + Math.cos(angle) * (radius - 40);
            const ty = centerY + Math.sin(angle) * (radius - 40);
            ctx.fillText(i.toString(), tx, ty);
          }
        }
        // Draw direction labels and store their hitboxes
          windDirectionLabels.forEach((label, i) => {
          const angleDeg = i * 22.5;
          const angle = degToRad(angleDeg);
          const tx = centerX + Math.cos(angle) * (radius + 40);
          const ty = centerY + Math.sin(angle) * (radius + 40);

          ctx.font = "bold 16px sans-serif";
          ctx.textAlign = "center";
          ctx.textBaseline = "middle";
          ctx.fillStyle = selectedWindDirections.has(label) ? "black" : "gray";
          ctx.fillText(label, tx, ty);

          // Approximate hitbox for each label
          const metrics = ctx.measureText(label);
          const width = metrics.width;
          const height = 16;
          labelHitboxes.push({
            label,
            x: tx - width / 2,
            y: ty - height / 2,
            width,
            height,
          });
        })
      }

      // Handle canvas click
      canvas.addEventListener("click", (e) => {
        const rect = canvas.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        for (const box of labelHitboxes) {
          if (
            x >= box.x &&
            x <= box.x + box.width &&
            y >= box.y &&
            y <= box.y + box.height
          ) {
            if (selectedWindDirections.has(box.label)) {
              selectedWindDirections.delete(box.label);
            } else {
              console.log("in else");
              selectedWindDirections.add(box.label);
              console.log(selectedWindDirections);
            }
            drawCompass();
            break;
          }
        }
      });

      canvas.addEventListener("mousemove", (e) => {
        const rect = canvas.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        let hovering = false;
        for (const box of labelHitboxes) {
          if (
            x >= box.x &&
            x <= box.x + box.width &&
            y >= box.y &&
            y <= box.y + box.height
          ) {
            hovering = true;
            break;
          }
        }

        canvas.style.cursor = hovering ? "pointer" : "default";
      });

      drawCompass();
    </script>
    </div>
    """
  end
end

# <Field name={:wind_directions}>
#               <Label>Wind directions:</Label>

#               <div id="wind-directions">
#                 {#for {value, label_map} <- @wind_direction_icon}
#                   <Label>
#                     {#if is_nil(@form[:wind_directions].value)}
#                       <input
#                         type="checkbox"
#                         name="url_form[wind_directions][]"
#                         id={"url_form_wind_directions-#{value}"}
#                         value={value}
#                         checked
#                       />
#                     {#else}
#                       <input
#                         type="checkbox"
#                         name="url_form[wind_directions][]"
#                         id={"url_form_wind_directions-#{value}"}
#                         value={value}
#                         checked={to_string(value) in @form[:wind_directions].value}
#                       />
#                     {/if}
#                     {label_map[@form[:indicator_direction].value]}
#                     {#if @form[:indicator_direction].value != "abbreviation"}
#                       ({label_map["abbreviation"]})
#                     {/if}
#                   </Label>
#                 {/for}
#               </div>
#             </Field>
