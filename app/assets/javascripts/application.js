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
//= require photoswipe/photoswipe
//= require photoswipe/photoswipe-ui-default
//= require js.cookies
//= require popper
//= require bootstrap
//= require_tree .

// Hide Turbolinks progress bar
document.addEventListener("turbolinks:load", function () {
  var progress = document.querySelector(".turbolinks-progress-bar");
  if (progress) {
    progress.style.display = "none";
  }
});

var ready;
var app = {};

function pageLoad() {
  setTimeout(function () {
    $("#notice_wrapper").fadeOut("slow", function () {
      $(this).remove();
    });
    $("#alert_wrapper").fadeOut("slow", function () {
      $(this).remove();
    });
  }, 4500);

  // Initialize sortable
  $(".sortable").railsSortable();

  // Initialize PhotoSwipe
  initPhotoSwipe();

  // Only load the map if necessary
  if ($("#bigmap").length > 0 || $(".minimap").length > 0) {
    var zoomControl = true;
    var attributionControl = true;
    var tileOptions = {
      subdomains: "abcd",
      minZoom: 0,
      maxZoom: 20,
      ext: "png",
      opacity: 0.5,
    };
    if ($(".minimap").length === 1) {
      // zoomControl = false;
      attributionControl = false;
    } else {
      tileOptions.attribution =
        'Map tiles by <a href="https://carto.com/">CartoDB</a>, under CC BY 3.0. Data by <a href="http://www.openstreetmap.org/">OpenStreetMap</a>, under ODbL.';
    }
    if (
      /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
        navigator.userAgent
      )
    ) {
      zoomControl = false;
    }

    app.basemap = L.tileLayer(
      "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
      tileOptions
    );

    // Return to the last-used map extent, or use a default extent
    var lat = Cookies.get("lat") || 0;
    var lng = Cookies.get("lng") || 27;
    var zoom = Cookies.get("zoom") || 3;
    app.leafletMap = new L.Map("map", {
      center: [lat, lng],
      zoom: zoom,
      maxZoom: 8,
      minZoom: 2,
      layers: [app.basemap],
      maxBounds: L.latLngBounds(L.latLng(-90, -180), L.latLng(90, 180)),
      zoomControl: zoomControl,
      attributionControl: attributionControl,
    });

    // Fetch geocoded posts
    var postId = $(".post_id").data("id") || null;
    var postLat = $(".post_id").data("latitude") || null;
    var postLong = $(".post_id").data("longitude") || null;
    getPosts(postId, postLat, postLong);

    // Store the last map extent in cookies
    app.leafletMap.on("zoomend", function () {
      updateCookies();
    });
    app.leafletMap.on("moveend", function () {
      updateCookies();
    });
  }

  function updateCookies() {
    Cookies.set("lat", app.leafletMap.getCenter().lat);
    Cookies.set("lng", app.leafletMap.getCenter().lng);
    Cookies.set("zoom", app.leafletMap.getZoom());
  }

  function getPosts(postID, postLat, postLong) {
    // Request posts with a lat/long
    var url = window.location.origin + "/getpins/index.json";
    $.ajax({
      dataType: "text",
      url: url,
      beforeSend: function (jqXHR, settings) {
        // send the post ID
        jqXHR.postID = postID;
        jqXHR.postLat = postLat;
        jqXHR.postLong = postLong;
      },
      success: function (data, textStatus, jqXHR) {
        var postID = jqXHR.postID || null;
        var postLat = jqXHR.postLat || null;
        var postLong = jqXHR.postLong || null;
        drawEvents(data, postID, postLat, postLong);
      },
      error: function () {
        console.log("Error with Index map");
      },
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
      fillOpacity: 0.8,
    };

    // Add the posts to the map
    var jsonLayer = L.geoJson(geojson, {
      pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, geojsonMarkerOptions);
      },
      onEachFeature: function (feature, layer) {
        var popupContent;
        if (feature.properties.title != undefined) {
          popupContent = feature.properties.title;
          if (feature.properties.url != undefined) {
            popupContent =
              "<p><strong><a class='mapTitle' href='" +
              feature.properties.url +
              "''>" +
              feature.properties.title +
              "</a></strong></p>";
          }
          if (feature.properties.photo !== undefined) {
            popupContent +=
              "<a href='" +
              feature.properties.url +
              "''><img width='240px' height='159px' class='mapPhoto' src='" +
              feature.properties.photo +
              "'></a>";
          }
        }
        layer.bindPopup(popupContent);
      },
    });
    // var featureGroup = L.featureGroup();
    // featureGroup.addLayer(jsonLayer);
    var markers = L.markerClusterGroup({
      spiderfyOnMaxZoom: true,
      showCoverageOnHover: false,
      zoomToBoundsOnClick: true,
      spiderfyDistanceMultiplier: 1.5,
    });
    markers.addLayer(jsonLayer);
    app.leafletMap.addLayer(markers);
    // featureGroup.addTo(app.leafletMap);

    // If we are on a Post page, zoom to the post
    if (postLat !== null && postLong !== null) {
      app.leafletMap.flyTo([postLat, postLong], 5);
    }
  }
}

function initPhotoSwipe() {
  var pswpElement = document.querySelector(".pswp");
  if (!pswpElement) {
    console.error("PhotoSwipe root element not found");
    return;
  }

  // build items array for all photos on the page
  var items = [];
  $(".image-link").each(function () {
    var $link = $(this);
    var img = new Image();
    var item = {
      src: $link.attr("href"),
      title: $link.attr("data-title"),
      w: 0,
      h: 0,
    };

    // Preload image to get dimensions
    img.onload = function () {
      item.w = this.width;
      item.h = this.height;
    };
    img.src = $link.attr("href");

    items.push(item);
  });

  if (items.length === 0) {
    return;
  }

  // define options (if needed)
  var options = {
    index: 0,
    bgOpacity: 0.8,
    showHideOpacity: true,
    shareEl: false,
    tapToClose: true,
    tapToToggleControls: true,
    closeOnScroll: false,
    history: false,
    getThumbBoundsFn: function (index) {
      var thumbnail = document.querySelectorAll(".image-link")[index];
      if (!thumbnail) {
        return null;
      }
      var rect = thumbnail.getBoundingClientRect();
      return {
        x: rect.left,
        y: rect.top + window.pageYOffset,
        w: rect.width,
      };
    },
    // Add these options to handle image loading
    preload: [1, 1],
    showAnimationDuration: 0,
    hideAnimationDuration: 0,
    maxSpreadZoom: 2,
    getDoubleTapZoom: function (isMouseClick, item) {
      return item.initialZoomLevel < 0.7 ? 1 : 1.5;
    },
  };

  // Remove any existing click handlers
  $(".image-link").off("click");

  // Initializes and opens PhotoSwipe for all photos
  $(".image-link").on("click", function (e) {
    e.preventDefault();
    e.stopPropagation();

    var $clickedLink = $(this);
    var index = $(".image-link").index($clickedLink);
    if (index === -1) {
      return;
    }

    options.index = index;

    try {
      // Create a new gallery instance
      var gallery = new PhotoSwipe(
        pswpElement,
        PhotoSwipeUI_Default,
        items,
        options
      );

      // Handle image loading errors
      gallery.listen("imageLoadComplete", function (index, item) {
        if (!item.w || !item.h) {
          var img = new Image();
          img.onload = function () {
            item.w = this.width;
            item.h = this.height;
            gallery.invalidateCurrItems();
            gallery.updateSize(true);
          };
          img.src = item.src;
        }
      });

      // Add class when gallery opens
      gallery.listen("beforeChange", function () {
        pswpElement.classList.add("pswp--open");
      });

      // Remove class and cleanup when gallery closes
      gallery.listen("close", function () {
        pswpElement.classList.remove("pswp--open");
        // Ensure the gallery is properly destroyed
        setTimeout(function () {
          gallery.destroy();
          // Force cleanup of any remaining elements
          var scrollWrap = pswpElement.querySelector(".pswp__scroll-wrap");
          if (scrollWrap) {
            scrollWrap.remove();
          }
        }, 0);
      });

      gallery.init();
    } catch (error) {
      console.error("Error initializing PhotoSwipe:", error);
    }
  });
}

// Initialize PhotoSwipe when the document is ready
$(document).ready(function () {
  initPhotoSwipe();
});

// Reinitialize PhotoSwipe after Turbolinks navigation
$(document).on("turbolinks:load", function () {
  initPhotoSwipe();
});

$(document).on("turbolinks:load", pageLoad);
