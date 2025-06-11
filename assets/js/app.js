// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import { encode, decode, PunkixHooks} from "punkix";
import Hooks from "./_hooks"
import topbar from "../vendor/topbar"
import "../css/app.css"

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
	hooks: {...PunkixHooks, ...Hooks},
	// encode: encode,
	// decode: decode,
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

// Store the state of details in localStorage and restore them on update
function initDetails() {
	for (detail of document.querySelectorAll("details")) {
		detail.addEventListener("toggle", (event) => {
			const key = `details_${detail.id}`
			if (detail.open) {
				localStorage.setItem(key, true)
			} else
				localStorage.removeItem(key)
			}
			)
	}
}
function restoreDetailsStates() {
	for (detail of document.querySelectorAll("details")) {
		if (detail.id) {
			if (localStorage.getItem(`details_${detail.id}`)) {
				detail.setAttribute("open", "")
			}
		}
	}
}
document.addEventListener("phx:update", restoreDetailsStates)
document.addEventListener('DOMContentLoaded', initDetails);

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
