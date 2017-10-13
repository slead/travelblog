var ready;
var app = {}
ready = function() {

	if ( $("#map").length ) {

		app.basemap = L.tileLayer('https://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.{ext}', {
			attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
			subdomains: 'abcd',
			minZoom: 0,
			maxZoom: 20,
			ext: 'png'
		});

		app.leafletMap = new L.Map("map", {
	    center: [40, -73],
	    zoom: 3,
	    maxZoom: 9,
	    minZoom: 2,
	    layers: [app.basemap],
	    maxBounds: L.latLngBounds(L.latLng(-90, -180), L.latLng(90, 180))
	  });
	}
};

$(document).on('turbolinks:load', ready);