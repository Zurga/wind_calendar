defmodule WeatherCalendarWeb.Components.WindDirection do
  use WeatherCalendarWeb.Component

  def render(assigns) do
    ~F"""
    <head>
      <meta charset="UTF-8">
      <title>Wind Rose Compass</title>
      <style>
        div {
        background: white;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        margin: 0;
        }

        canvas {
        cursor: pointer;
        }
      </style>
    </head>
    <div>
      <canvas id="compass" width="512" height="512" />

      <script>
      const canvas = document.getElementById("compass");
      const ctx = canvas.getContext("2d");
      const centerX = canvas.width / 2;
      const centerY = canvas.height / 2;
      const radius = 200;

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

      // All directions are selected initially
      const selectedWindDirections = new Set(directions);

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
        for (let i = 0; i < 16; i++) {
          const angleDeg = i * 22.5;
          const angle = degToRad(angleDeg);
          const label = directions[i];
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
        }
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
