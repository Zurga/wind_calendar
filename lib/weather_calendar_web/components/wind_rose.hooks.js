export default {
	mounted() {
		const canvas = this.el.querySelector("canvas");
		canvas.height = canvas.parentNode.offsetHeight;
		canvas.width = canvas.parentNode.offsetWidth;
		const input = this.el.querySelector("input");
		const resetBtn = this.el.querySelector("button");
		const ctx = canvas.getContext("2d");
		const center = { x: ctx.canvas.width / 2, y: ctx.canvas.height / 2 };
		const handleRadius = 8;
		const stepCount = 16;
		const stepAngle = 360 / stepCount;
		const tickLength = 10;
		const radius = (center.x / 2.5) - handleRadius;
		const labelRadius = radius + 18;
		const lineColor = "#cfd5e2";

		const labels16 = [
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

		const state = {
			startIndex: 0,
			endIndex: 0, // full circle if untouched
			touched: false,
		};

		resetBtn.addEventListener("click", () => {
			reset()
		})

		function reset() {
			state.startIndex = 0
			state.endIndex = 0
			state.touched = false
			updateWindDirections()
		}
		 
		let dragging = null;

		function stepToAngle(index) {
			return index * stepAngle;
		}

		function angleToXY(angle, r = radius) {
			const rad = ((angle - 90) * Math.PI) / 180;
			return {
				x: center.x + r * Math.cos(rad),
				y: center.y + r * Math.sin(rad),
			};
		}

		function xyToNearestStep(x, y) {
			const dx = x - center.x;
			const dy = y - center.y;
			// if (((x - center.x) ** 2 + (y - center.y) ** 2) < labelRadius) {
			// 	return false
			// }
			let angle = (Math.atan2(dy, dx) * 180) / Math.PI + 90;
			if (angle < 0) angle += 360;
			return Math.round(angle / stepAngle) % stepCount;
		}

		function drawTicksAndLabels() {
			for (let i = 0; i < stepCount; i++) {
				const angle = stepToAngle(i);
				const rad = ((angle - 90) * Math.PI) / 180;

				const inner = {
					x: center.x + (radius - tickLength) * Math.cos(rad),
					y: center.y + (radius - tickLength) * Math.sin(rad),
				};
				const outer = {
					x: center.x + (radius + tickLength / 2) * Math.cos(rad),
					y: center.y + (radius + tickLength / 2) * Math.sin(rad),
					// x: center.x + (radius + tickLength) * Math.cos(rad),
					// y: center.y + (radius + tickLength) * Math.sin(rad)
				};

				ctx.beginPath();
				ctx.moveTo(inner.x, inner.y);
				ctx.lineTo(outer.x, outer.y);
				ctx.strokeStyle = lineColor;
				ctx.lineWidth = 1.5;
				ctx.stroke();

				if ( i % 4 === 0) {
					const labelPos = angleToXY(angle, labelRadius);
					ctx.fillStyle = "#373c44";
					ctx.font = '400 100% system-ui';
					ctx.textAlign = "center";
					ctx.textBaseline = "middle";
					ctx.fillText(labels16[i], labelPos.x, labelPos.y);
				}
			}
		}

		function isFullCircle() {
			return state.startIndex === state.endIndex && !state.touched;
		}

		function draw() {
			ctx.clearRect(0, 0, canvas.width, canvas.height);

			// Circle
			ctx.beginPath();
			ctx.arc(center.x, center.y, radius, 0, Math.PI * 2);
			ctx.strokeStyle = lineColor;
			ctx.lineWidth = 2;
			ctx.stroke();

			drawTicksAndLabels();

			// Fill selected arc
			const startAngle = stepToAngle(state.startIndex);
			const endAngle = stepToAngle(state.endIndex);
			const startRad = ((startAngle - 90) * Math.PI) / 180;
			const endRad = isFullCircle()
				? startRad + Math.PI * 2
				: ((endAngle - 90) * Math.PI) / 180;

			ctx.beginPath();
			ctx.moveTo(center.x, center.y);
			ctx.arc(center.x, center.y, radius, startRad, endRad, false);
			ctx.closePath();
			ctx.fillStyle = "rgba(223,227,235, 0.5)";
			ctx.fill();

			// Handles
			const startPos = angleToXY(startAngle);
			const endPos = angleToXY(endAngle);
			ctx.beginPath();
			ctx.arc(startPos.x, startPos.y, handleRadius, 0, Math.PI * 2);
			// ctx.fillText(">", startPos.x, startPos.y)
			// canvasArrow(ctx, startPos.x, startPos.y, startPos.x + 30, startPos.y + 30)
			ctx.fillStyle = "#525f7a";
			ctx.fill();
			ctx.beginPath();
			ctx.arc(endPos.x, endPos.y, handleRadius, 0, Math.PI * 2);
			ctx.fillStyle = "#525f7a";
			ctx.fill();

			// Show reset button if touched or not full circle
			resetBtn.style.display = isFullCircle() ? "none" : "block";

			if (!isFullCircle()) {
				ctx.beginPath();
				ctx.arc(center.x, center.y, handleRadius * 2, 0, Math.PI * 2);
				ctx.fillStyle = "#525f7a";
				ctx.fill();
			}
		}

		function getHandleAt(x, y) {
			const startPos = angleToXY(stepToAngle(state.startIndex));
			const endPos = angleToXY(stepToAngle(state.endIndex));
			if (Math.hypot(x - startPos.x, y - startPos.y) < handleRadius + 5)
				return "startIndex";
			if (Math.hypot(x - endPos.x, y - endPos.y) < handleRadius + 5)
				return "endIndex";
			return null;
		}

		function moveNearestHandleTo(index) {
			const d = (a, b) =>
				Math.min(Math.abs(a - b), stepCount - Math.abs(a - b));
			const dStart = d(index, state.startIndex);
			const dEnd = d(index, state.endIndex);
			if (dStart <= dEnd) {
				state.startIndex = index;
			} else {
				state.endIndex = index;
			}
			state.touched = true;
			draw();
			updateWindDirections();
		}

		function getRangeIndices() {
			const result = [];
			let i = state.startIndex;
			while (true) {
				result.push(i);
				if (i === state.endIndex) break;
				i = (i + 1) % stepCount;
			}
			return result;
		}

		function updateWindDirections() {
			const windDirections = getRangeIndices();
			input.value = windDirections;
			input.dispatchEvent(new Event("change", { bubbles: true }));
		}

		canvas.addEventListener("mousedown", (e) => {
			const rect = canvas.getBoundingClientRect();
			const x = e.clientX - rect.left;
			const y = e.clientY - rect.top;
			dragging = getHandleAt(x, y);
			if (!dragging) {
				const index = xyToNearestStep(x, y);
				moveNearestHandleTo(index);
			}
		});

		canvas.addEventListener("mousemove", (e) => {
			if (!dragging) return;
			const rect = canvas.getBoundingClientRect();
			const x = e.clientX - rect.left;
			const y = e.clientY - rect.top;
			const index = xyToNearestStep(x, y);
				state[dragging] = index;
				state.touched = true;
			// } else {
			// 	console.log("reset")
			// 	reset()
			// }
			draw();
		});

		canvas.addEventListener("mouseup", () => {
			if (dragging !== null) updateWindDirections();
			dragging = null;
		});

		canvas.addEventListener("mouseleave", () => {
			dragging = null;
		});

		resetBtn.addEventListener("click", () => {
			state.startIndex = 0;
			state.endIndex = 0;
			state.touched = false;
			draw();
			updateWindDirections();
		});

		draw();
	},
};
