var ready;
var app = {}
ready = function() {

	if ( $("#map").length ) {

    maptiks.trackcode='fa969613-9010-44fb-b866-1750026fcdb3';

    var zoomControl = true;
    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
     zoomControl = false;
    }

		app.basemap = L.tileLayer('https://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.{ext}', {
			attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
			subdomains: 'abcd',
			minZoom: 0,
			maxZoom: 20,
			ext: 'png',
			opacity: 0.5
		});

    // Return to the last-used map extent, or use a default extent
    var lat = Cookies.get('lat') || 0;
    var lng = Cookies.get('lng') || 27;
    var zoom = Cookies.get('zoom') || 3;
		app.leafletMap = new L.Map("map", {
	    center: [lat, lng],
	    zoom: zoom,
	    maxZoom: 8,
	    minZoom: 2,
	    layers: [app.basemap],
	    maxBounds: L.latLngBounds(L.latLng(-90, -180), L.latLng(90, 180)),
      zoomControl: zoomControl
	  });

    // Fetch geocoded posts
    getPosts();

    // Store the last map extent in cookies
    app.leafletMap.on('zoomend', function() {
      updateCookies();
    });
    app.leafletMap.on('moveend', function() {
      updateCookies();
    });

  }

  function updateCookies(){
    Cookies.set("lat", app.leafletMap.getCenter().lat);
    Cookies.set("lng", app.leafletMap.getCenter().lng);
    Cookies.set("zoom", app.leafletMap.getZoom());
  }

  function getPosts() {
    // Request posts with a lat/long
    var url = "posts.json?map=true";
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
    var jsonLayer = L.geoJson(geojson, {
      pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, geojsonMarkerOptions);
      },
      onEachFeature: function (feature, layer) {
        var popupContent;
        if(feature.properties.title != undefined) {
          popupContent = feature.properties.title;
          if(feature.properties.url != undefined) {
            popupContent = "<p><strong><a class='mapTitle' href='" + feature.properties.url + "''>" + feature.properties.title + "</a></strong></p>";
          }
          if (feature.properties.photo !== undefined) {
            popupContent += "<a href='" + feature.properties.url + "''><img width='240px' height='159px' class='mapPhoto' src='" + feature.properties.photo + "'></a>";
          }
        }
        layer.bindPopup(popupContent);
      }
    });
    // var featureGroup = L.featureGroup();
    // featureGroup.addLayer(jsonLayer);
    var markers = L.markerClusterGroup({
      spiderfyOnMaxZoom: true,
      showCoverageOnHover: false,
      zoomToBoundsOnClick: true,
      spiderfyDistanceMultiplier: 1.5
    });
    markers.addLayer(jsonLayer);
    app.leafletMap.addLayer(markers);
    // featureGroup.addTo(app.leafletMap);

  }
};

$(document).on('turbolinks:load', ready);
