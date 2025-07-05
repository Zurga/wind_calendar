
const startPos = [52.3735, 4.90608];
const Leaflet = {
	mounted() {
		const startPosition =
			(this.el.dataset.lat !== undefined && [
				this.el.dataset.lat,
				this.el.dataset.lng,
			]) ||
			startPos;

		const latlngInput = this.el.querySelector('input')
		console.log(latlngInput)
		const map = L.map(this.el).setView(startPosition, 7);
		map.on('click', (e) => {
    	clearMap()
    	L.marker(e.latlng, { draggable: true })
    		.addTo(window.markerGroup)
    		.on("moveend", (e) => {
    			const latlng = e.target.getLatLng();
          updateLatLng(latlng, latlngInput)
      	}
      )
      updateLatLng(e.latlng, latlngInput)
		})
		const markerGroup = L.featureGroup([]).addTo(map);
		window.map = map;
		window.markerGroup = markerGroup;
		const tiles = L.tileLayer(
			"https://tile.openstreetmap.org/{z}/{x}/{y}.png",
			{
				maxZoom: 19,
				attribution:
					'&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
			},
		).addTo(map);
	},
};


function updateLatLng(latlng, latlngInput) {
      latlngInput.value = `${latlng.lat},${latlng.lng}`
			latlngInput.dispatchEvent(new Event("change", {bubbles: true}))
	}
function clearMap() {
	window.markerGroup.clearLayers()
}

window.addEventListener("phx:reset-map", (data) => clearMap());

const Copy = {
	mounted() {
		// Copy the text inside the text field
		this.el.addEventListener("click", () => {
	  navigator.clipboard.writeText(this.el.dataset.value);
	  })
	}
}

const WindCompassHook = {
	mounted() {
	  const canvas = this.el;
	  const ctx = canvas.getContext("2d");
  
	  const windDirectionLabels = [
		"N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
		"S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"
	  ];
  
	  const centerX = canvas.width / 2;
	  const centerY = canvas.height / 2;
	  const radius = 200;
	  const labelHitboxes = [];
	  const selected = new Set(windDirectionLabels); // All selected by default
  
	  // This input is updated on selection changes (like in the Leaflet hook, but not working)
	  const windInput = this.el.querySelector('input');
  
	  const degToRad = (deg) => (deg - 90) * (Math.PI / 180);
	  const styles = getComputedStyle(document.documentElement);
	  const activeColor = styles.getPropertyValue('--pico-color').trim();
	  const mutedColor = styles.getPropertyValue('--pico-muted-color').trim();
	  function drawCompass() {
		ctx.clearRect(0, 0, canvas.width, canvas.height);
		labelHitboxes.length = 0;
  
		// Ticks
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
		  ctx.strokeStyle = mutedColor; // Use muted color for ticks
		  ctx.stroke();
  
		  // Degree labels every 10°
		  ctx.font = "12px sans-serif";
		  ctx.fillStyle = mutedColor; 
		  ctx.textAlign = "center";
		  ctx.textBaseline = "middle";
		  const tx = centerX + Math.cos(angle) * (radius - 40);
		  const ty = centerY + Math.sin(angle) * (radius - 40);
		  ctx.fillText(i.toString(), tx, ty);
		}
		
		// Direction labels
		windDirectionLabels.forEach((label, i) => {
		  const angleDeg = i * 22.5;
		  const angle = degToRad(angleDeg);
		  const tx = centerX + Math.cos(angle) * (radius + 40);
		  const ty = centerY + Math.sin(angle) * (radius + 40);
  
		  ctx.font = "bold 16px sans-serif";
		  ctx.textAlign = "center";
		  ctx.textBaseline = "middle";
		  ctx.fillStyle = selected.has(label) ? activeColor : mutedColor;
		  ctx.fillText(label, tx, ty);
  
		  const metrics = ctx.measureText(label);
		  const w = metrics.width;
		  const h = 16;
		  labelHitboxes.push({ label, x: tx - w / 2, y: ty - h / 2, w, h });
		});
	  }
  
	  //TODO somehow update the array of directions
	  function updateWindDirections() {
		console.log(windInput)
		if (!windInput) return windDirectionLabels;
		windInput.value = Array.from(selected).join(",");
		windInput.dispatchEvent(new Event("change", { bubbles: true }));
	  }
  
	  function toggleDirection(label) {
		const inputId = `wind_direction_${label}`;
		const existing = document.getElementById(inputId);
  
		if (selected.has(label)) {
		  selected.delete(label);
		  existing?.remove();
		} else {
		  selected.add(label);
		  const hidden = document.createElement("input");
		  hidden.type = "hidden";
		  hidden.name = "url_form[wind_directions][]";
		  hidden.value = label;
		  hidden.id = inputId;
		  canvas.parentNode.appendChild(hidden);
		}
  
		updateWindDirections();
		drawCompass();
	  }
  
	  canvas.addEventListener("click", (e) => {
		const rect = canvas.getBoundingClientRect();
		const x = e.clientX - rect.left;
		const y = e.clientY - rect.top;
  
		for (let box of labelHitboxes) {
		  if (x >= box.x && x <= box.x + box.w && y >= box.y && y <= box.y + box.h) {
			toggleDirection(box.label);
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
		  if (x >= box.x && x <= box.x + box.w && y >= box.y && y <= box.y + box.h) {
			hovering = true;
			break;
		  }
		}
  
		canvas.style.cursor = hovering ? "pointer" : "default";
	  });
  
	  drawCompass();
	  updateWindDirections(); // initial sync
	},
  };

export { Leaflet, Copy, WindCompassHook }
