function get_ratings() {
	document.getElementById("rate_outcome").value =
		Array.from(document.getElementsByTagName("input"))
		.filter(v => v.type == "range")
		.sort(function(a, b) {return b.value - a.value})
		.reduce(function(a, v) {
			a.push(`${v.name}, ${v.value}`)
			return a
		}, [])
		.join("\n")
}

window.addEventListener("load", function(e){
	document.getElementById("rate_button").onclick = get_ratings
})
