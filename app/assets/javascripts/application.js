// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require jquery
//= require jquery_ujs
//= require jquery-ui/widgets/sortable
//= require rails_sortable
//= require leaflet
//= require leaflet.markercluster
//= require tinymce
//= require lightbox
//= require js.cookies
//= require popper
//= require bootstrap
//= require_tree .

var ready;
var app = {}

function pageLoad() {
  setTimeout(function() {
    $('#notice_wrapper').fadeOut("slow", function() {
      $(this).remove();
    })
    $('#alert_wrapper').fadeOut("slow", function() {
      $(this).remove();
    })
  }, 4500);

  // re-initialize Lightbox on Turbolinks page load
  if ( $(".lightboxpics").length === 0) {
    lightbox.init();
    $('.sortable').railsSortable();
  }

  // Only load the map if necessary
  if ( $("#bigmap").length > 0 || $(".minimap").length > 0) {
    var zoomControl = true;
    var attributionControl = true;
    var tileOptions = {
      subdomains: 'abcd',
      minZoom: 0,
      maxZoom: 20,
      ext: 'png',
      opacity: 0.5
    }
    if ( $(".minimap").length === 1) {
      // zoomControl = false;
      attributionControl = false;
    } else {
      tileOptions.attribution = 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>';
    }
    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
     zoomControl = false;
    }

    app.basemap = L.tileLayer('https://stamen-tiles-{s}.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}.{ext}', tileOptions);

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
      zoomControl: zoomControl,
      attributionControl: attributionControl
    });

    // Fetch geocoded posts
    var postId = $(".post_id").data('id') || null;
    var postLat = $(".post_id").data('latitude') || null;
    var postLong = $(".post_id").data('longitude') || null;
    getPosts(postId, postLat, postLong);

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

  function getPosts(postID, postLat, postLong) {
    // Request posts with a lat/long
    var url = window.location.origin + "/posts.json?map=true";
    $.ajax({
      dataType: 'text',
      url: url,
      beforeSend: function (jqXHR, settings) {
        // send the post ID
        jqXHR.postID = postID;
        jqXHR.postLat= postLat;
        jqXHR.postLong = postLong;
      },
      success: function(data, textStatus, jqXHR) {
        var postID = jqXHR.postID || null;
        var postLat = jqXHR.postLat || null;
        var postLong = jqXHR.postLong || null;
        drawEvents(data, postID, postLat, postLong);
      },
      error: function() {
        console.log("Error with Index map");
      }
    });
  }

  function drawEvents(data, postID, postLat, postLong) {
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

    // If we are on a Post page, zoom to the post
    if (postLat !== null && postLong !== null){
      app.leafletMap.flyTo([postLat, postLong], 5);
    }

  }

}

$(document).on('turbolinks:load', pageLoad);
