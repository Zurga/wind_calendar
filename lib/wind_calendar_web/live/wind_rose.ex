defmodule WindCalendarWeb.WindRose do
  use WindCalendarWeb.LiveView

  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(test: "testing")}
  end

  def render(assigns) do
    ~F"""
    <h3>{@test}</h3>

    <head>
      <meta charset="UTF-8">
      <title>Wind Rose</title>
      <style>
        body {
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        background: #fff;
        }

        svg {
        width: 400px;
        height: 400px;
        }

        .direction-label {
        font: bold 12px sans-serif;
        text-anchor: middle;
        alignment-baseline: middle;
        }

        .degree-label {
        font: bold 10px sans-serif;
        text-anchor: middle;
        alignment-baseline: middle;
        }

        .arc {
        fill: none;
        stroke: limegreen;
        stroke-opacity: 0.5;
        stroke-width: 15;
        }

        .tick {
        stroke: black;
        stroke-width: 1;
        }

        .tick.major {
        stroke-width: 2;
        }
      </style>
    </head>
    <div id="wind-compass-container" phx-update="ignore">
      <svg viewBox="0 0 400 400" id="windRose" />

      <script>
          const svg = document.getElementById("windRose");
          const cx = 200;
          const cy = 200;
          const r = 160;

          const directions = [
            "N",
            "NNE",
            "NE",
            "ENE",
            "E",
            "ESE",
            "SE",
            "SSE",
            "S",
            "SSW",
            "SW",
            "WSW",
            "W",
            "WNW",
            "NW",
            "NNW",
          ];

          // Draw direction labels
          directions.forEach((dir, i) => {
            const angle = (i * 22.5 - 90) * (Math.PI / 180); // -90 to rotate starting from top
            const x = cx + Math.cos(angle) * (r - 25);
            const y = cy + Math.sin(angle) * (r - 25);

            const text = document.createElementNS(
              "http://www.w3.org/2000/svg",
              "text"
            );
            text.setAttribute("x", x.toString());
            text.setAttribute("y", y.toString());
            text.classList.add("direction-label");
            text.textContent = dir;
            svg.appendChild(text);
          });

          // Draw tick marks every 10 degrees
          for (let deg = 0; deg < 360; deg += 10) {
            const angle = (deg - 90) * (Math.PI / 180);
            const isMajor = deg % 30 === 0;

            const outer = r;
            const inner = r - (isMajor ? 10 : 5);

            const x1 = cx + Math.cos(angle) * outer;
            const y1 = cy + Math.sin(angle) * outer;
            const x2 = cx + Math.cos(angle) * inner;
            const y2 = cy + Math.sin(angle) * inner;

            const line = document.createElementNS(
              "http://www.w3.org/2000/svg",
              "line"
            );
            line.setAttribute("x1", x1.toString());
            line.setAttribute("y1", y1.toString());
            line.setAttribute("x2", x2.toString());
            line.setAttribute("y2", y2.toString());
            line.classList.add("tick");
            if (isMajor) line.classList.add("major");
            svg.appendChild(line);
          }

          for (let deg = 0; deg < 360; deg += 30) {
            const angle = (deg - 90) * (Math.PI / 180);
            const x = cx + Math.cos(angle) * (r + 20);
            const y = cy + Math.sin(angle) * (r + 20);

            const label = document.createElementNS(
              "http://www.w3.org/2000/svg",
              "text"
            );
            label.setAttribute("x", x.toString());
            label.setAttribute("y", y.toString());
            label.classList.add("degree-label");
            label.textContent = deg.toString();
            svg.appendChild(label);
          }
          // Draw green arc for selected wind direction (e.g., 200° to 40°)
          const startDeg = 200;
          const endDeg = 40;
          const startAngle = (startDeg - 90) * (Math.PI / 180);
          const endAngle = (endDeg - 90) * (Math.PI / 180);

          const largeArc = (endDeg + 360 - startDeg) % 360 > 180 ? 1 : 0;

          const xStart = cx + Math.cos(startAngle) * r;
          const yStart = cy + Math.sin(startAngle) * r;
          const xEnd = cx + Math.cos(endAngle) * r;
          const yEnd = cy + Math.sin(endAngle) * r;

          const arcPath = `
              M ${xStart} ${yStart}
              A ${r} ${r} 0 ${largeArc} 1 ${xEnd} ${yEnd}
            `;

          const arc = document.createElementNS(
            "http://www.w3.org/2000/svg",
            "path"
          );
          arc.setAttribute("d", arcPath);
          arc.classList.add("arc");
          svg.appendChild(arc);
        </script>
    </div>
    """
  end
end
