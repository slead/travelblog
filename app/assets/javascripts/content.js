var ready;
var app = {}
ready = function() {

	if ( $("#map").length ) {

		app.basemap = L.tileLayer('https://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.{ext}', {
			attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
			subdomains: 'abcd',
			minZoom: 0,
			maxZoom: 20,
			ext: 'png',
			opacity: 0.5
		});

		app.leafletMap = new L.Map("map", {
	    center: [40, -73],
	    zoom: 2,
	    maxZoom: 6,
	    minZoom: 2,
	    layers: [app.basemap],
	    maxBounds: L.latLngBounds(L.latLng(-90, -180), L.latLng(90, 180))
	  });
	

	    // Fetch the posts within  the current map extent, and re-fetch them when it changes
    mapSearch();
    app.leafletMap.on('moveend', mapSearch);

  }

  function mapSearch() {
    // Request posts within the current map extent

    extent = app.leafletMap.getBounds();
    var northEast = extent._northEast.wrap();
    var southWest = extent._southWest.wrap();
    currentZoom = app.leafletMap.getZoom();

    url = "posts.json?bbox=" + southWest.lat + "," + southWest.lng + "," + northEast.lat + "," + northEast.lng + "&zoom=" + currentZoom;
    $.ajax({
      dataType: 'text',
      url: url,
      success: drawEvents,
      error: function() {
        console.log("Error with Index map");
      }
    });
  }

  function drawEvents(data) {
    var geojson = $.parseJSON(data);
    var geojsonMarkerOptions = {
	    radius: 8,
	    fillColor: "#FF0000",
	    color: "#000",
	    weight: 1,
	    opacity: 1,
	    fillOpacity: 0.8
	  };

    // Add the posts to the map
    jsonLayer = L.geoJson(geojson, {
      pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, geojsonMarkerOptions);
      },
      onEachFeature: function (feature, layer) {
        if(feature.properties.title != undefined) {
          if(feature.properties.url != undefined) {
            layer.bindPopup("<a href='" + feature.properties.url + "''>" + feature.properties.title + "</a>");
          } else {
            layer.bindPopup(feature.properties.title);
          }
        }
      }
    });
    featureGroup = L.featureGroup()
    featureGroup.addLayer(jsonLayer)
    featureGroup.addTo(app.leafletMap);

  }
};

$(document).on('turbolinks:load', ready);