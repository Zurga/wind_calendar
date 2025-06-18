
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

export { Leaflet, Copy }
